data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}
locals {
  s3_origin_id = "myS3Origin"
  account_id = data.aws_caller_identity.current.account_id
}

module "s3_bucket_for_logs" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket= "${var.environment}-${var.product}-${local.account_id}-login"
  #bucket = "dev.vtex.logging"
  #acl    = "log-delivery-write"
  
  tags = {
     ResourceType = "BucketS3"
  }

  # Allow deletion of non-empty bucket
  force_destroy = true

  attach_elb_log_delivery_policy = true  # Required for ALB logs
  attach_lb_log_delivery_policy  = true  # Required for ALB/NLB logs
}