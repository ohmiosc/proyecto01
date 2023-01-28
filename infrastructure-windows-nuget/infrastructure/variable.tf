variable "region" {
  default     = "us-east-1"
  type        = string
  description = "AWS Region"
}

variable "product" {
  default     = "pagoefectivo"
  type        = string
  description = "The name of the LB. This name must be unique within your AWS account."
}

variable "environment" {
  default     = "production"
  type        = string
  description = "The envrionment where it will be deployed"

}

variable "environment_prefix" {
  default     = "prod"
  type        = string
  description = "The envrionment prefix where it will be deployed"
}

variable "service" {
  default     = "nuget"
  type        = string
  description = "The envrionment"
}

variable "ec2_type" {
  default     = "t3.medium"
  type        = string
  description = "Type the intance ec2"
}

variable "ec2_subnet" {
  default     = "subnet-05d004db959189ad7"
  type        = string
  description = "Subnet the EC"
}

variable "ec2_vpcid" {
  default     = "vpc-02be8863353229246"
  type        = string
  description = "Id Vpc"
}

variable "use_alb" {
  default     = "pagoefectivo-prod-legacy-alb"
  type        = string
  description = "nombre del balanceador donde obtendran el SG para permiso puerto 80"
}