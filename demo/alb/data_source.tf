data "aws_vpc" "selected" {
  tags = {
    Name = var.vpc_name
  }
}

#data "aws_subnet_ids" "tier_subnets" {
#  vpc_id = data.aws_vpc.selected.id
#  tags = {
#    Tier = var.tag_tier
#  }
#}

#data "aws_subnet_ids" "private_subnets" {
#  vpc_id = data.aws_vpc.selected.id
#  tags = {
#    Tier = "private"
#  }
#}
#data "aws_caller_identity" "current" {}