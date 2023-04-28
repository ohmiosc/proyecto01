data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "cw_canarys" {
  bucket        = "cw-canaries-${data.aws_caller_identity.current.account_id}-${var.service}"
  force_destroy = "true"

}
resource "aws_s3_bucket_public_access_block" "access_good_cw" {
  bucket = aws_s3_bucket.cw_canarys.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.cw_canarys.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = aws_s3_bucket.cw_canarys.id

  rule {
    id = "/"
    noncurrent_version_expiration {
      noncurrent_days = 60
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "cw_canarys-policy" {
  bucket = aws_s3_bucket.cw_canarys.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "CwCanariesPolicy"
    Statement = [
      {
        Sid    = "Permissions"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_caller_identity.current.account_id
        }
        Action   = ["s3:*"]
        Resource = ["${aws_s3_bucket.cw_canarys.arn}/*"]
      },
      {
        Sid    = "AWSConfigBucketSecureTransport"
        Effect = "Deny"
        Principal = {
          AWS = data.aws_caller_identity.current.account_id
        }
        Action   = ["s3:*"]
        Resource = ["${aws_s3_bucket.cw_canarys.arn}/*", "${aws_s3_bucket.cw_canarys.arn}"]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      } 
    ]
  })
}