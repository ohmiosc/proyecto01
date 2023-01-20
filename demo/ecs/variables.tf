variable "region" {
  default = "us-west-2"
  type        = string
  description = "AWS Region"
}
variable "product" {
  default     = "syndeo"
  type        = string
  description = "The name of the LB. This name must be unique within your AWS account."
}

variable "environment" {
  default     = "pre1a"
  type        = string
  description = "The envrionment where it will be deployed"

}

variable "environment_prefix" {
  default     = "pre1a"
  type        = string
  description = "The envrionment prefix where it will be deployed"

}