resource "aws_wafv2_web_acl" "acl-plugin" {
  name  = "${var.environment_prefix}-${var.product}-waf-acl"
  description = "Plugin-Prestashop-Cloudfront-Waf"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "rate-limit-ip"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 10000
        aggregate_key_type = "IP"
      
        scope_down_statement {
          geo_match_statement {
            country_codes = ["US", "NL"]
          }
        }
      }  
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "AWS-WAF-rate-rule"
      sampled_requests_enabled   = false
      }
  }
  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "AWS-WAF-Plugin"
    sampled_requests_enabled   = false
    }
}

#resource "aws_wafv2_web_acl_association" "association_waf" {
#    depends_on = [
#      aws_cloudfront_distribution.s3_distribution
#    ]
#    resource_arn = aws_cloudfront_distribution.s3_distribution.arn
#    web_acl_arn  = aws_wafv2_web_acl.acl-plugin.arn
#}