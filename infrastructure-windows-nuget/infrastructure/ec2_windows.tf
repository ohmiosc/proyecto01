# Create EC2 Instance
resource "aws_instance" "windows-server" {
  ami                    = data.aws_ami.lastet.id
  instance_type          = var.ec2_type
  subnet_id              = var.ec2_subnet
  vpc_security_group_ids = [aws_security_group.allow_rdp.id]
  source_dest_check      = false
  key_name               = data.aws_key_pair.ec2_key.key_name
  user_data            = data.template_file.windows-userdata.rendered
  iam_instance_profile = aws_iam_instance_profile.nuget-server-profile.id
  monitoring           = true
  ebs_optimized        = true
  # root disk
  root_block_device {
    volume_size           = 150
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  #ebs_block_device {
  #  device_name           = "xvdd"
  #  volume_size           = 50
  #  volume_type           = "gp2"
  #  delete_on_termination = true
  #  encrypted             = true
  #}

  tags = {
    Name            = "${var.environment_prefix}-${var.product}-windows-${var.service}"
    AV              = "defender"
    OperatingSystem = "windowsserver"
    #Backup          = "yes"
  }

}
resource "aws_ec2_tag" "ec2_eni" {
  resource_id = aws_instance.windows-server.primary_network_interface_id
  key         = "Vectra"
  value       = "mirroring"
}
resource "aws_lb_target_group" "tg-ec2-windows" {
  name     = "${var.environment_prefix}-${var.product}-win-${var.service}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.ec2_vpcid
  #target_type = "instance"
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 10
    matcher             = "200-299"
    path                = "/"
    timeout             = 5
    unhealthy_threshold = 2
  }
  tags = {
    ResourceType = "TargetGroup"
  }
}
resource "aws_lb_target_group_attachment" "sg_attachment" {
  target_group_arn = aws_lb_target_group.tg-ec2-windows.arn
  target_id        = aws_instance.windows-server.id
  port             = 80
  depends_on       = [aws_lb_target_group.tg-ec2-windows]
}

resource "aws_lb_listener_rule" "static-asyncapproved" {
  listener_arn = data.aws_lb_listener.alb_https_arn.arn
  #priority     = 101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-ec2-windows.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  condition {
    host_header {
      values = ["nuget.server.orbis.pe"]
    }
  }
}