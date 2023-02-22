module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "AWS-VPC-021"
  cidr = "172.21.0.0/16"

  azs             = ["us-west-2a", "us-west-2c"]
  private_subnets = ["172.21.10.0/24", "172.21.11.0/24"]
  public_subnets  = ["172.21.50.0/24", "172.21.51.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames   = true
  enable_dns_support     = true
}