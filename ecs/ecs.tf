
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "${var.product}-${var.environment_prefix}"
  public_key = "${tls_private_key.this.public_key_openssh}"
}

module "role_ecs" {
  #source  = "git::ssh://git@bitbucket.org/orbisunt/terraform-aws-module-role"
  source  = "./modules/role_ecs/"

  product     = "${var.product}"
  project     = "ecs"
  environment = "${var.environment_prefix}"
  service     = "ec2"
  policy      = "${data.template_file.policy_ecs.rendered}"
}

resource "aws_iam_instance_profile" "profile_ecs" {
  name = "ec2.${var.product}.${var.environment_prefix}.ecs"
  role = "${module.role_ecs.name}"
}

module "sg_ecs" {
  #source  = "git::ssh://git@bitbucket.org/orbisunt/terraform-aws-module-securitygroup.git"
  source  = "./modules/sg_ecs/"

  name_prefix = "${var.product}-${var.environment_prefix}-ecs"
  vpc_id = "${data.aws_vpc.selected.id}"
}

module "sg_ecs_rule_1" {
  #source            = "git::ssh://git@bitbucket.org/orbisunt/terraform-module-securitygroup-rule.git"
  source  = "./modules/sg_ecs_rule_1/"

  ports             = ["22"]
  protocol          = "tcp"
  security_group_id = "${module.sg_ecs.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sg_ecs_rule_2" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "TCP"
  source_security_group_id = "${module.sg_ecs.id}"
  security_group_id        = "${module.sg_ecs.id}"
}

resource "aws_security_group_rule" "sg_ecs_rule_3" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "ALL"
  security_group_id        = "${module.sg_ecs.id}"
  cidr_blocks              = ["0.0.0.0/0"]
}

resource "aws_ecs_cluster" "ecs" {
  name = "${var.ecs_name}"
  tags = "${var.tags}"
}

module "autoscaling_ecs" {
  #source               = "git::ssh://git@bitbucket.org/orbisunt/terraform-aws-module-autoscaling-ecs.git"
  source               = "./modules/autoscaling_ecs/"

  product              = "${var.product}"
  environment          = "${var.environment}"
  environment_prefix   = "${var.environment_prefix}"
  image_id             = "${var.ami_ecs}"
  instance_type        = "${var.instance_type}"
  ebs_optimized        = false
  key_name             = "${aws_key_pair.this.key_name}"
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  volume_size_0        = 100
  iam_instance_profile = "${aws_iam_instance_profile.profile_ecs.arn}"
  security_groups      = ["${module.sg_ecs.id}"]
  # target_group_arns    = ["${data.aws_lb_target_group.selected.arn}"]

  # target_group_arns    = [
  #   "arn:aws:elasticloadbalancing:ap-northeast-1:929226109038:loadbalancer/app/lumingo-laboratory/852f5c286d97eb78"
  # ]
  vpc_zone_identifier  = "${data.aws_subnets.private.ids}"
  user_data            = "${data.template_file.data_ecs.rendered}"
}