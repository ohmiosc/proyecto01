data "aws_vpc" "selected" {
	tags  = {
    Name = "${var.vpc_name}"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = "${data.aws_vpc.selected.id}"

  tags = {
    Tier = "public"
  }
}
###
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  tags = {
    Tier = "public"
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  tags = {
    Tier = "private"
  }
}
###
data "aws_subnet_ids" "private" {
  vpc_id = "${data.aws_vpc.selected.id}"

  tags = {
    Tier = "private"
  }
}

data "template_file" "data_ecs" {
  template = "${file("templates/data_ecs.tpl")}"
  vars = {
    ecs_name    = "${var.ecs_name}"
    region      = "${var.region}"
  }
}
data "template_file" "policy_ecs" {
  template = "${file("templates/policy_ecs.tpl")}"
}

# data "aws_security_group" "ecs" {
#   filter {
#     name = "tag:Name"
#     values = ["{$var.product}-${var.environment}-ecs"]
#   }
# }