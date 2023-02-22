resource "aws_security_group" "allow_rdp" {
  name        = "${var.product}-${var.environment_prefix}-windows-${var.service}-sg"
  description = "${var.product}-${var.environment_prefix}-windows-${var.service}-sg"
  vpc_id      = var.ec2_vpcid

  ingress {
    description = "Access port RDP "
    from_port   = 3389 #  By default, the windows server listens on TCP port 3389 for RDP
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  ingress {
    description = "Access Service HTTP Balancer internal"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    #cidr_blocks = ["10.0.0.0/8"]
    security_groups = [tolist(data.aws_alb.alb_internal.security_groups)[0]]
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