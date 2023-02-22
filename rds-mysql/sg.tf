resource "aws_security_group" "sg-default" {
  name        = "${var.product}-${var.environment_prefix}-${var.project}-sg"
  description = "${var.environment_prefix}-mysql-sg"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "Access port postgres "
    from_port   = 3306 #  By default, the windows server listens on TCP port 3306 for mysql
    to_port     = 3306
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