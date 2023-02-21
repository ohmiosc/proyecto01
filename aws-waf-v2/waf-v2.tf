resource "aws_wafv2_ip_set" "ipset-natgw" {
  name               = "${var.product}-${var.environment_prefix}-ipset-natgw"
  description        = "Whitelist - Lista de IPs NatGW."
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  #addresses          = ["52.41.2.36/32", "54.203.44.193/32", "38.74.7.20/32"]
  addresses = ["${data.aws_nat_gateway.ngw[0].public_ip}/32", "${data.aws_nat_gateway.ngw[1].public_ip}/32"]
}

resource "aws_wafv2_ip_set" "ipset-vpnpaysafe" {
  name               = "${var.product}-${var.environment_prefix}-ipset-vpnpaysafe"
  description        = "Whitelist - Lista de IPs VPN-Paysafe."
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["18.214.115.95/32", "99.14.137.73/32", "87.120.141.75/32", "87.120.141.76/32", "213.208.158.212/32", "38.74.6.20/32", "38.117.126.11/32", "54.209.34.118/32", "38.117.126.142/32", "44.208.219.192/32", "115.114.129.142/32", "38.74.7.20/32", "20.73.226.224/31", "54.154.244.180/32", "87.120.141.83/32", "52.154.244.181/32", "52.154.244.180/31", "12.131.147.68/32", "208.97.237.201/32", "213.208.158.220/32", "38.113.180.40/32", "208.87.232.0/21"]
}

resource "aws_wafv2_web_acl" "waf-acl-1" {
  #  depends_on = [
  #    aws_wafv2_ip_set.ipset-natgw
  #  ]
  name        = "${var.product}-${var.environment_prefix}-waf-acl"
  description = "Payment - Waf de ALB"
  scope       = "REGIONAL"

  default_action {
    block {}
  }

  ### RULE ###  
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
      metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "${var.product}-${var.environment_prefix}-rule-natgw-access"
    priority = 2
    action {
      allow {}
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.ipset-natgw.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${var.product}-${var.environment_prefix}-rule-natgw-access"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "${var.product}-${var.environment_prefix}-rule-vpnpaysafe-access"
    priority = 3
    action {
      allow {}
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.ipset-vpnpaysafe.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.product}-${var.environment_prefix}-rule-vpnpaysafe-access"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.product}-${var.environment_prefix}-waf-acl"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "association_waf" {
  resource_arn = data.aws_alb.alb_internal.arn
  web_acl_arn  = aws_wafv2_web_acl.waf-acl-1.arn
}