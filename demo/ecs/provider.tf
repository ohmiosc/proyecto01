provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Product      = "syndeo"
      Environment  = "pre1a"
      Project      = "pgp"
      Squad        = "nuevos proyectos"
    }
  }
}

terraform {
  # backend "s3" {}
  backend "s3" {
    bucket = "orbis.terraform.state"
    key    = "temp/terraform/temp//ecs/terraform.state"
    region = "us-east-1"
  }
  required_version = ">= 0.12.0"
}