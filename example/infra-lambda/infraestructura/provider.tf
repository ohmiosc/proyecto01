provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Product     = "pe-vtex"
      Environment = "pre"
      Squad       = "Apicips"
      Project     = "pe-vtex"
      Owner       = "pe"
    }
  }
}

terraform {
  #
  # backend "s3" {}
  backend "s3" {
    bucket = "orbis.terraform.state"
    key    = "pe/infrastructure/vtex/terraform/pre/alb-lambda/terraform.state"
    region = "us-east-1"
  }
  required_version = ">= 0.12.0"
}