data "aws_vpc" "selected" {
  tags = {
    Name = "${var.vpc_name}"
  }
}

#data "aws_subnets" "private" {
#  filter {
#    name   = "vpc-id"
#    values = [data.aws_vpc.selected.id]
#  }

#  tags = {
#    Tier = "private"
#  }
#}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  tags = {
    "paysafe:subnet-type" = "private-edge"
  }
}

#data "aws_kms_alias" "secret-m" {
#  name = "alias/aws/secretsmanager"
#}

data "aws_subnets" "private-default" {
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