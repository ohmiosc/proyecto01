variable "region" {
  default     = "eu-west-1"
  type        = string
  description = "AWS Region"
}
variable "vpc_name" {
  type        = string
  default     = "AWS-VPC-033"
  description = "Name of VPC"
}

variable "use_alb" {
  default     = "serverless-jenkins-crtl-alb"
  type        = string
  description = "nombre del balanceador donde obtendran el SG para permiso puerto 80"
}

variable "product" {
  default     = "pagoefectivo"
  type        = string
  description = "The name of the LB. This name must be unique within your AWS account."
}

variable "environment" {
  default     = "dev"
  type        = string
  description = "The envrionment where it will be deployed"

}

variable "environment_prefix" {
  default     = "dev"
  type        = string
  description = "The envrionment prefix where it will be deployed"
}