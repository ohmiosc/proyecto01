resource "aws_wafv2_ip_set" "white-lits" {
  name               = "${var.product}-${var.environment_prefix}-ips-pgp"
  description        = "BlackLists - lista de ips NatG."
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["52.41.2.36/32", "54.203.44.193/32"]
}

resource "aws_wafv2_web_acl" "waf-acl-1" {
  depends_on = [
    aws_wafv2_ip_set.white-lits
  ]
  name        = "${var.product}-${var.environment_prefix}-waf-acl"
  description = "PGP - Waf de ALB"
  scope       = "REGIONAL"

  default_action {
    block {}
  }
  rule {
    name     = "rule-ips-Nat-VPC32"
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

resource "aws_wafv2_web_acl_association" "association_waf" {
  depends_on = [
    module.alb
  ]
  resource_arn = module.alb.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.waf-acl-1.arn
}
