data "aws_vpc" "selected" {
  tags = {
    Name = var.vpc_name
  }
}
data "aws_nat_gateways" "ngws" {
  vpc_id = var.vpc_id

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_nat_gateway" "ngw" {
  count = length(data.aws_nat_gateways.ngws.ids)
  id    = tolist(data.aws_nat_gateways.ngws.ids)[count.index]
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