variable "product" {
  type = string
  default     = "test"
}

variable "environment" {
  type  = string
  default     = "test"
}

variable "environment_prefix" {
  type        = string  
  description = "The envrionment prefix where it will be deployed"
  default     = "test"
}

variable "region" {
  type = string
  default     = "eu-west-1"
}

variable "ecs_name" {
  type = string
  default     = "test-h"
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

variable "tags" {
  default     = {}
  type        = map
  description = "A mapping of tags to assign to all resources."
}