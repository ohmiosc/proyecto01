resource "aws_route53_record" "public_name" {
  depends_on = [
    aws_cloudfront_distribution.s3_distribution
  ]
  count   = length(var.domain) > 0 && length(var.zone_id_public) > 0 ? 1 : 0
  name    = "${var.product}.${var.domain}"
  zone_id = var.zone_id_public
  type    = "CNAME"
  ttl     = "60"
  records = [
    aws_cloudfront_distribution.s3_distribution.domain_name
  ]
}
      
resource "aws_route53_record" "private_name" {
    depends_on = [
    aws_cloudfront_distribution.s3_distribution
  ]
  count   = length(var.domain) > 0 && length(var.zone_id_private) > 0 ? 1 : 0
  name    = "${var.product}.${var.domain}"
  zone_id = var.zone_id_private
  type    = "CNAME"
  ttl     = "60"
  records = [
    aws_cloudfront_distribution.s3_distribution.domain_name
  ]
}