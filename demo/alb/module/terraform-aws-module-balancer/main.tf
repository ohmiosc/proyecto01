resource "aws_lb" "default" {
  
  count = var.enabled ? 1 : 0
  
  load_balancer_type = "application"
  name = var.name
  internal = var.internal
  security_groups = ["${aws_security_group.default.id}"]
  subnets = var.subnets
  idle_timeout = var.idle_timeout
  enable_deletion_protection = var.enable_deletion_protection
  enable_http2 = var.enable_http2
  ip_address_type = var.ip_address_type
  access_logs {
    bucket  = var.access_logs_bucket
    prefix  = var.access_logs_prefix
    enabled = var.access_logs_enabled
  }
  tags = var.tags
  drop_invalid_header_fields = true
}

resource "aws_lb_target_group" "default" {
  count = var.enabled ? 1 : 0

  name   = "${var.name}-default"
  vpc_id = var.vpc_id
  port = var.target_group_port
  protocol = var.target_group_protocol
  target_type = var.target_type
  deregistration_delay = var.deregistration_delay
  slow_start = var.slow_start
  health_check {
    path = var.health_check_path
    healthy_threshold = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout = var.health_check_timeout
    interval = var.health_check_interval
    matcher = var.health_check_matcher
    port = var.health_check_port
    protocol = var.health_check_protocol
  }
  tags = var.tags
  depends_on = [aws_lb.default]
}
resource "aws_lb_listener" "https" {
  count = local.enable_https_listener ? 1 : 0
  load_balancer_arn = aws_lb.default[count.index].arn
  port              = var.https_port
  protocol          = "HTTPS"
  ssl_policy = var.ssl_policy
  certificate_arn = var.certificate_arn
  default_action {
    target_group_arn = aws_lb_target_group.default[count.index].arn
    type = "forward"
    }
  }

#resource "aws_lb_listener" "http" {
#  count = local.enable_http_listener ? 1 : 0
#
#  load_balancer_arn = aws_lb.default[count.index].arn
#  port              = var.http_port
#  protocol          = "HTTP"
#  default_action {
#    target_group_arn = aws_lb_target_group.default[count.index].arn
#    type = "forward"
#    }
#}

#resource "aws_lb_listener" "redirect_http_to_https" {
#  count = local.enable_redirect_http_to_https_listener ? 1 : 0
#  
#  load_balancer_arn = aws_lb.default[count.index].arn
#  port              = var.http_port
#  protocol          = "HTTP"
#  default_action {
#    type = "redirect"

#    redirect {
#      port        = var.https_port
#      protocol    = "HTTPS"
#      status_code = "HTTP_301"
#    }
#  }
#}

resource "aws_lb_listener_rule" "https" {
  count = local.enable_https_listener ? 1 : 0

  listener_arn = aws_lb_listener.https[count.index].arn
  priority     = var.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default[count.index].arn
  }
  condition {
    path_pattern {
    values = var.listener_rule_condition_values
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

#resource "aws_lb_listener_rule" "http" {
#  count = local.enable_http_listener ? 1 : 0

#  listener_arn = aws_lb_listener.http[count.index].arn
#  priority     = var.listener_rule_priority

#  action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.default[count.index].arn
#  }

#  condition {
#    path_pattern {
#    values = var.listener_rule_condition_values
#    }
#  }

#  lifecycle {
#    create_before_destroy = true
#  }
#}

resource "aws_security_group" "default" {
  description = "default"

  name   = local.security_group_name
  vpc_id = var.vpc_id

  tags = merge(tomap({"Name" = local.security_group_name}), var.tags)
}

locals {
  security_group_name = "${var.name}"
}

resource "aws_security_group_rule" "ingress_https" {
  count = local.enable_https_listener ? 1 : 0

  type              = "ingress"
  from_port         = var.https_port
  to_port           = var.https_port
  protocol          = "tcp"
  cidr_blocks       = var.ingress_cidr_blocks
  security_group_id = aws_security_group.default.id
  description = "ingress https"
}

#resource "aws_security_group_rule" "ingress_http" {
#  count = var.enabled && var.enable_http_listener ? 1 : 0
#  description = "ingress http"
#  type              = "ingress"
#  from_port         = var.http_port
#  to_port           = var.http_port
#  protocol          = "tcp"
#  cidr_blocks       = var.ingress_cidr_blocks
#  security_group_id = aws_security_group.default.id
#}

resource "aws_security_group_rule" "egress" {
  count = var.enabled ? 1 : 0
  description = "egress rule"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

locals {
  enable_https_listener                  = var.enabled && var.enable_https_listener
#  enable_http_listener                   = var.enabled && var.enable_http_listener && !(var.enable_https_listener && var.enable_redirect_http_to_https_listener)
#  enable_redirect_http_to_https_listener = var.enabled && var.enable_http_listener && (var.enable_https_listener && var.enable_redirect_http_to_https_listener)
}