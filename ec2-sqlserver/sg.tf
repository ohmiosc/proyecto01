resource "aws_security_group" "allow_rdp" {
  name        = "${var.product}-${var.environment_prefix}-bd-ec2-sg"
  description = "${var.product}-${var.environment_prefix}-bd-ec2-sg"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "Access port sqlserver"
    from_port   = 50789
    to_port     = 50789
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }
  ingress {
    description = "Access port RDP "
    from_port   = 3389
    to_port     = 3389
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