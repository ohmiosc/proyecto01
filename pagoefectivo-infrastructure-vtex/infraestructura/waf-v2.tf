resource "aws_wafv2_ip_set" "white-lits" {
  name               = "${var.product}-${var.environment_prefix}-ips-vtex"
  description = "Integracion vtex-pe - lista de ips vtex"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["3.229.80.75/32", "3.230.248.18/32", "3.230.89.127/32", "3.90.211.67/32"]
}

resource "aws_wafv2_web_acl" "acl-vtex" {
  depends_on = [
    aws_wafv2_ip_set.white-lits
  ]
  name  = "${var.product}-${var.environment_prefix}-waf-acl"
  description = "Integracion vtex-pe - Waf de ALB"
  scope = "REGIONAL"

  default_action {
    block {}
  }
  rule {
    name     = "rule-ips-vtex"
    priority = 2
    action {
      allow {}
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.white-lits.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "friendly-rule-metric-name"
      sampled_requests_enabled   = false
    }
  }
  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "friendly-rule-metric-name"
      sampled_requests_enabled   = false
    }
  }


  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = false
  }
}

#resource "aws_wafv2_web_acl_association" "association_waf" {
#    depends_on = [
#      module.alb
#    ]
#    resource_arn = module.alb.alb_arn
#    web_acl_arn  = aws_wafv2_web_acl.acl-vtex.arn
#}