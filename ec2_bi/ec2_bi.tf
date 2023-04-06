# Create EC2 Instance
resource "aws_instance" "bi-server" {
  ami                    = data.aws_ami.lastet.id #"ami-02327a8492177b0c4"
  instance_type          = var.ec2_type
  subnet_id              = data.aws_subnets.private.ids[0] #"subnet-00c3ff8f43ac7defb" #
  vpc_security_group_ids = [aws_security_group.allow_bi.id]
  source_dest_check      = false
  key_name               = data.aws_key_pair.ec2_key.key_name
  user_data              = base64encode(data.template_file.test.rendered)
  iam_instance_profile   = aws_iam_instance_profile.bi-profile.id
  monitoring             = true
  ebs_optimized          = true
  # root disk
  root_block_device {
    volume_size           = 100
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name            = "${var.product}-${var.environment_prefix}-bi-ec2"
    Backup          = "no"
    #Auto-Off        = "yes"
  }

}
resource "aws_ec2_tag" "ec2_eni" {
  resource_id = aws_instance.bi-server.primary_network_interface_id
  key         = "Vectra"
  value       = "mirroring"
}

## SECRET ##
