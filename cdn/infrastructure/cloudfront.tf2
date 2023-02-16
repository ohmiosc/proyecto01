resource "aws_cloudfront_response_headers_policy" "security_headers_policy" {
  name = "${var.environment}-${var.product}-policy-headers"
  comment = "Policy Headers plugin"
  security_headers_config {
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    referrer_policy {
      referrer_policy = "same-origin"
      override        = true
    }
    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }
    strict_transport_security {
      access_control_max_age_sec = "63072000"
      include_subdomains         = true
      preload                    = true
      override                   = true
    }
    #content_security_policy {
    #  content_security_policy = "frame-ancestors 'none'; default-src 'none'; img-src 'self'; script-src 'self'; style-src 'self'; object-src 'none'"
    #  override                = true
    #}
  }
}


resource "aws_cloudfront_origin_access_identity" "oai_plugins" {
  comment = "${var.product}.${var.domain}"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
    depends_on = [
      aws_s3_bucket.bk-plugins
    ]
  origin {
    domain_name = aws_s3_bucket.bk-plugins.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai_plugins.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = false
  comment             = "${var.product}.${var.domain}"

  logging_config {
    include_cookies = true
    bucket          = "aes-siem-929226109038-log.s3.amazonaws.com"
    prefix          = "AWSLogs/929226109038/CloudFront/global/E37BN25XGQZAZF/standard/"
  }

  aliases = ["${var.product}.${var.domain}"]
  

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers_policy.id


    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    #viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn = "${var.arn_certificate}"
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"

  }
web_acl_id = aws_wafv2_web_acl.acl-plugin.arn
}