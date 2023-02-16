provider "aws" {
  region = var.region
    default_tags {
    tags = {
      Product      = "plugin"
      Environment  = "prod"
      Squad        = "apicips"
      Project      = "prestashop"
      Owner        = "pe"

    }
  }
}

terraform {
  #
  # backend "s3" {}
  backend "s3" {
    bucket = "orbis.terraform.state"
    key    = "pe/infrastructure/plugins-prestashop/terraform/test/s3-cloudfront/terraform.state"
    region = "us-east-1"
  }
  required_version = ">= 0.12.0"
}