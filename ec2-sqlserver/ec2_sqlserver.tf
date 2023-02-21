# Create EC2 Instance
resource "aws_instance" "windows-server" {
  ami                    = "ami-02327a8492177b0c4" #data.aws_ami.lastet.id
  instance_type          = var.ec2_type
  subnet_id              = data.aws_subnets.private.ids[0] #"subnet-00c3ff8f43ac7defb" #
  vpc_security_group_ids = [aws_security_group.allow_rdp.id]
  source_dest_check      = false
  key_name               = data.aws_key_pair.ec2_key.key_name
  #user_data              = data.template_file.windows-userdata.rendered
  iam_instance_profile = aws_iam_instance_profile.sql-server-profile.id
  monitoring           = true
  ebs_optimized        = true
  # root disk
  root_block_device {
    volume_size           = 100
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  ebs_block_device {
    device_name           = "xvdb"
    volume_size           = 500
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }
  ebs_block_device {
    device_name           = "xvdc"
    volume_size           = 500
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }
  ebs_block_device {
    device_name           = "xvdd"
    volume_size           = 500
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }
  ebs_block_device {
    device_name           = "xvde"
    volume_size           = 200
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }


  tags = {
    Name            = "${var.product}-${var.environment_prefix}-sqlserver-ec2"
    AV              = "defender"
    OperatingSystem = "windowsserver"
    Backup          = "yes"
    Auto-Off        = "yes"
  }

}
resource "aws_ec2_tag" "ec2_eni" {
  resource_id = aws_instance.windows-server.primary_network_interface_id
  key         = "Vectra"
  value       = "mirroring"
}