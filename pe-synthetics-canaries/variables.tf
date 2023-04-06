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
  default     = "dev"
  type        = string
  description = "The envrionment where it will be deployed"

}

variable "service" {
  default     = "canary"
  type        = string
  description = "This name must be unique within your AWS account."
}

variable "environment_prefix" {
  default     = "dev"
  type        = string
  description = "The envrionment prefix where it will be deployed"

}

