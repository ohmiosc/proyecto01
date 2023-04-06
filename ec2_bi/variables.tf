variable "region" {
  default     = "eu-west-1"
  type        = string
  description = "AWS Region"
}

variable "product" {
  default     = "pe"
  type        = string
  description = "This name must be unique within your AWS account."
}

variable "environment" {
  default     = "prod{"
  type        = string
  description = "The envrionment where it will be deployed"

}

variable "service" {
  default     = "pentaho"
  type        = string
  description = "This name must be unique within your AWS account."
}

variable "environment_prefix" {
  default     = "prod"
  type        = string
  description = "The envrionment prefix where it will be deployed"

}

variable "vpc_name" {
  type    = string
  default = "AWS-VPC-042"
}

variable "ec2_type" {
  type    = string
  default = "r6i.large"
}

variable "key" {
  default     = "018"
  type        = string
  description = "key"

}