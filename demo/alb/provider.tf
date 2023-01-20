provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Product      = "services"
      Environment  = "pre"
      Project      = "mod4"
      Squad        = "apicips"
    }
  }
}

terraform {
  # backend "s3" {}
  backend "s3" {
    bucket = "orbis.terraform.state"
    key    = "temp/terraform/temp2/alb/terraform.state"
    region = "us-east-1"
  }
  required_version = ">= 0.12.0"
}