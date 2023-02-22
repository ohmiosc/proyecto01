provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Product     = "pagoefectivo"
      Environment = "prod"
      Squad       = "infraestructura"
      Project     = "nuget-server"
      Owner       = "pe"

    }
  }
}

terraform {
  #
  # backend "s3" {}
  backend "s3" {
    bucket = "orbis.terraform.state"
    key    = "infrastructure/production/nuget-server/terraform.state"
    region = "us-east-1"
  }
  required_version = ">= 0.12.0"
}