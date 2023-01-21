resource "aws_route53_record" "public_name" {
  depends_on = [
    aws_globalaccelerator_accelerator.ga
  ]
  count   = length(var.domain) > 0 && length(var.zone_id_public) > 0 ? 1 : 0
  name    = "${var.environment_prefix}.${var.domain}"
  zone_id = var.zone_id_public
  type    = "A"

  alias {
    name                   = aws_globalaccelerator_accelerator.ga.dns_name
    zone_id                = aws_globalaccelerator_accelerator.ga.hosted_zone_id
    evaluate_target_health = true
  }
  #ttl     = "60"
  #records = [
  #  aws_cloudfront_distribution.s3_distribution.domain_name
  #]
}

#resource "aws_route53_record" "private_name" {
#    depends_on = [
#    aws_cloudfront_distribution.s3_distribution
#  ]
#  count   = length(var.domain) > 0 && length(var.zone_id_private) > 0 ? 1 : 0
#  name    = "${var.environment_prefix}.${var.product}.${var.domain}"
#  zone_id = var.zone_id_private
#  type    = "CNAME"
#  ttl     = "60"
#  records = [
#    aws_cloudfront_distribution.s3_distribution.domain_name
#  ]
#}
