provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Product     = "pe"
      Environment = "noprod"
      Project     = "dev"
      Squad       = "cloud"
      IaC         = "Terraform"
    }
  }
}

terraform {
  # backend "s3" {}
  backend "s3" {
    bucket = "orbis.terraform.state"
    key    = "temp/terraform/temp2/waf-v2/terraform.state"
    region = "us-east-1"
  }
  required_version = ">=1.3.0"
}