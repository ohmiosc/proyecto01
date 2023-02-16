data "aws_caller_identity" "current" {}

output "account_id" {
  value = local.account_id
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.bk-plugins.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai_plugins.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_policy_plugins" {
  bucket = aws_s3_bucket.bk-plugins.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_s3_bucket" "bk-plugins" {
    for_each = toset([
    "bucket-1",
    "bucket-2",
    "bucket-3"
  ])

  #bucket = "${var.environment}.${var.product}.${var.domain}-${local.account_id}"
 bucket ="${var.environment}.${var.product}.${var.domain}-${local.account_id}-${each.value}"
}

resource "aws_s3_bucket_versioning" "versioning_plugins" {
  bucket = aws_s3_bucket.bk-plugins.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "bucket-plugins-acl" {
  bucket = aws_s3_bucket.bk-plugins.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "access_public" {
  bucket = aws_s3_bucket.bk-plugins.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls=true
  restrict_public_buckets = true
}

locals {
  s3_origin_id = "myS3Origin"
  account_id = data.aws_caller_identity.current.account_id
}
