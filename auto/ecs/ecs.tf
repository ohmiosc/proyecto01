
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

resource "aws_security_group" "allow_sg" {
  name        = "${var.product}-${var.environment_prefix}-sg"
  description = "Virtual firewall that controls the traffic"
  vpc_id      = "${data.aws_vpc.selected.id}"

  ingress {
    description = "Access port all "
    from_port   = 0 #  By default, the windows server listens on TCP port 3389 for RDP
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 # ingress {
 #   description = "Access Service HTTP Balancer internal"
 #   from_port   = 0
 #   to_port     = 65535
 #   protocol    = "tcp"
 #   #cidr_blocks = ["10.0.0.0/8"]
 #   security_groups = "${aws_security_group.allow_sg.id}"
 # }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow egress traffic"
  }
}

#resource "aws_ecs_cluster" "ecs" {
#  name = "${var.ecs_name}"
#  tags = "${var.tags}"
#}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  version = "3.5.0"
  name = "${var.ecs_name}-ecs"

  container_insights = true

  tags = {
    ResourceType = "ecs"
  }
}
data "template_file" "test" {
  template = <<EOF
    #!/bin/bash

    stop ecs
    yum -y update && yum -y install vim telnet 
    yum update -y ecs-init

    echo "ECS_CLUSTER=${var.ecs_name}" >> /etc/ecs/ecs.config
    echo "AWS_DEFAULT_REGION=${var.region}" >> /etc/ecs/ecs.config
    echo "ECS_NUM_IMAGES_DELETE_PER_CYCLE=3" >> /etc/ecs/ecs.config
    echo "ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=1m" >> /etc/ecs/ecs.config
    echo "ECS_CHECKPOINT=false" >> /etc/ecs/ecs.config

    service docker restart && start ecs
  EOF
}

resource "aws_launch_template" "foo" {
  name = "pagoefectivo-pre-ecs-2023"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 100
    }
  }

  ebs_optimized = true
  image_id = "ami-08c011700cf146b89"
  instance_type = "r5.large"
  key_name = "${aws_key_pair.this.key_name}"
  iam_instance_profile {
    name = aws_iam_instance_profile.profile_ecs.name
  }
#  metadata_options {
#    http_endpoint               = "enabled"
#    http_tokens                 = "required"
#    http_put_response_hop_limit = 1
#    instance_metadata_tags      = "enabled"
#  }
  monitoring {
    enabled = true
  }
  vpc_security_group_ids = ["${aws_security_group.allow_sg.id}"]
  #user_data = "${data.template_file.data_ecs.rendered}"
  #user_data = "${data.template_file.test.rendered}"
  user_data = "${base64encode(data.template_file.test.rendered)}"
}

resource "aws_autoscaling_group" "this" {
  capacity_rebalance  = true
  name                      = "${var.product}-${var.environment_prefix}-ecs"
  #launch_configuration      = "${aws_launch_configuration.this.name}"
  max_size                  = "${var.max_size}"
  min_size                  = "${var.min_size}"
  desired_capacity          = "${var.min_size}"
  health_check_type         = "EC2"
  health_check_grace_period = 300
  #target_group_arns         = "${var.target_group_arns}"
  vpc_zone_identifier       = "${data.aws_subnets.private.ids}"
  default_cooldown          = 300
  termination_policies      =["OldestInstance", "NewestInstance", "OldestLaunchTemplate", "AllocationStrategy", "Default"]
    mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 1
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.foo.id
      }

      override {
        instance_type     = "r5.large"
        weighted_capacity = "1"
      }
    }
  }
  
  tag {
    key                 = "Name"
    value               = "${var.product}-${var.environment_prefix}-ecs"
    propagate_at_launch = true
  }

  tag {
    key                 = "Product"
    value               = "${var.product}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }
}
###
resource "aws_autoscaling_policy" "this" {
  name                   = "${var.product}-${var.environment_prefix}-ecs"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = "${aws_autoscaling_group.this.name}"
  policy_type            = "StepScaling"

  step_adjustment {
    scaling_adjustment = 1
    metric_interval_lower_bound = 0
    metric_interval_upper_bound = 10
  }
  step_adjustment {
    scaling_adjustment = 2
    metric_interval_lower_bound = 10
  }
}

resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name          = "${var.product}-${var.environment_prefix}-ecs"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "75"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.this.name}"
  }

  alarm_description = "Auto Scaling Increase CPU"
  alarm_actions     = ["${aws_autoscaling_policy.this.arn}"]
}