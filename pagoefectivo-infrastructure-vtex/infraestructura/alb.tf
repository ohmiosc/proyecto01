module "alb" {
  source = "../module/terraform-aws-module-balancer/"
  depends_on = [
    module.s3_bucket_for_logs
  ]
  name                = "${var.product}-${var.environment_prefix}-alb"
  vpc_id              = var.vpc_id
  subnets             = ["subnet-0437861ce4bb7932e", "subnet-017e2d9da3be809b0"]
  access_logs_bucket  = module.s3_bucket_for_logs.s3_bucket_id
  access_logs_prefix  = "${var.product}/${var.environment_prefix}/load-balancer"
  access_logs_enabled = true
  certificate_arn     = var.certificate_arn

  enable_https_listener                  = true
  enable_http_listener                   = false
  enable_redirect_http_to_https_listener = false

  internal            = false
  idle_timeout        = 120
  enable_http2        = false
  ip_address_type     = var.ip_address_type
  ssl_policy          = "ELBSecurityPolicy-TLS-1-2-2017-01"
  https_port          = 443
  http_port           = 80
  ingress_cidr_blocks = ["0.0.0.0/0"]

  target_group_port                = 80
  target_group_protocol            = "HTTP"
  target_type                      = "ip"
  deregistration_delay             = 600
  slow_start                       = 0
  health_check_path                = "/"
  health_check_healthy_threshold   = 3
  health_check_unhealthy_threshold = 3
  health_check_timeout             = 3
  health_check_interval            = 60
  health_check_matcher             = 200
  health_check_port                = "traffic-port"
  health_check_protocol            = "HTTP"
  listener_rule_priority           = 1
  listener_rule_condition_field    = "path-pattern"
  listener_rule_condition_values   = ["/test"]
  enabled                          = true

  tags = {
    ResourceType = "LoadBalancer"
  }
  enable_deletion_protection = false

}

data "aws_caller_identity" "current" {

}

data "aws_availability_zones" "available" {

}

module "s3_bucket_for_logs" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = "${var.environment_prefix}.${var.product}.logging"

  tags = {
    ResourceType = "BucketS3"
  }

  # Allow deletion of non-empty bucket
  force_destroy = true

  attach_elb_log_delivery_policy = true # Required for ALB logs
  attach_lb_log_delivery_policy  = true # Required for ALB/NLB logs
}