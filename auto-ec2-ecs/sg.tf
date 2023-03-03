resource "aws_security_group" "allow_sg" {
  name        = "${var.product}-${var.environment_prefix}-ec2-ecs-sg"
  description = "Virtual firewall that controls the traffic"
  vpc_id      = "${data.aws_vpc.selected.id}"

  ingress {
    description = "Access port all "
    from_port   = 0 #  By default, the windows server listens on TCP port 3389 for RDP
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow egress traffic"
  }
}