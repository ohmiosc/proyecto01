provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Product     = "pe"
      Environment = "nonprod"
      Squad       = "cloudengineer"
      Project     = "rds"
      Owner       = "pe"

    }
  }
}

terraform {
  #
  # backend "s3" {}
  backend "s3" {
    bucket = "orbis.terraform.state"
    key    = "pe/infrastructure/terraform/test/canary/terraform.state"
    region = "us-east-1"
  }
  required_version = ">= 0.12.0"
}