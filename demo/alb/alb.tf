module "alb" {
  source = "./module/terraform-aws-module-balancer/"
  depends_on = [
    module.s3_bucket_for_logs
  ]
  name                = "${var.product}-${var.environment_prefix}-alb"
  vpc_id              = var.vpc_id
  subnets             = ["subnet-0b9be442f7229d078", "subnet-0a00e0227101d5630"]
  access_logs_bucket  = module.s3_bucket_for_logs.s3_bucket_id
  access_logs_prefix  =  "logs/${var.product}/${var.environment_prefix}/load-balancer"
  access_logs_enabled = true
  certificate_arn     = var.certificate_arn

  enable_https_listener                  = true
  #enable_http_listener                   = false
  #enable_redirect_http_to_https_listener = false

  internal            = true
  idle_timeout        = 120
  enable_http2        = false
  ip_address_type     = var.ip_address_type
  ssl_policy          = "ELBSecurityPolicy-TLS-1-2-2017-01"
  https_port          = 443
  #http_port           = 80
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
