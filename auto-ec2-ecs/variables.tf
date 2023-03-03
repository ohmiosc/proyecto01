variable "product" {
  type = string
  default     = "pe"
}

variable "environment" {
  type  = string
  default     = "dev"
}

variable "environment_prefix" {
  type        = string  
  description = "The envrionment prefix where it will be deployed"
  default     = "dev"
}

variable "region" {
  type = string
  default     = "eu-west-1"
}

variable "ecs_name" {
  type = string
  default     = "serverless-jenkins-main"
}

variable "vpc_name" {
  type = string
  default     = "AWS-VPC-042"
}

variable "ami_ecs" {
  type = string
  default     = "ami-08c011700cf146b89"
}

variable "instance_type" {
  type = string
  default     = "r5.xlarge"
}

variable "max_size" {
  type = number
   default     = 1
}

variable "min_size" {
  type = number
   default     = 1
}