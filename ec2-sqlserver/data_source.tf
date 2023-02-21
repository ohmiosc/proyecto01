data "aws_key_pair" "ec2_key" {
  key_name           = "AWS-VPC-018"
  include_public_key = true

  filter {
    name   = "key-pair-id"
    values = ["key-0215f3636e7ff4145"]
  }
}

data "aws_ami" "lastet" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["pagoefectivo-windows-legacy-*"]
  }
}

data "aws_vpc" "selected" {
  tags = {
    Name = "${var.vpc_name}"
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  filter {
    name   = "availability-zone-id"
    values = ["euw1-az1"]
  }
  tags = {
    "paysafe:subnet-type" = "private-edge"
  }
}
