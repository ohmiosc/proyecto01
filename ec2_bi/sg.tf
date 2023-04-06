resource "aws_security_group" "allow_bi" {
  name        = "${var.product}-${var.environment_prefix}-bi-ec2-sg"
  description = "${var.product}-${var.environment_prefix}-bi-ec2-sg"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "Access port bi"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }
  ingress {
    description = "Access port linux"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
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