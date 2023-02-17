variable "region" { 
    type = string 
    default = "us-west-2"
}

#variable "lb_name" {
#    type = string
#    default = ""
#}

### Variable - Cross

variable "create" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

### Accelerator - main

variable "name" {
  description = "The name of the accelerator"
  type        = string
  default     = "ga-default-test"
}

variable "ip_address_type" {
  description = "The value for the address type. Defaults to `IPV4`. Valid values: `IPV4`"
  type        = string
  default     = "IPV4"
}

variable "enabled" {
  description = "Indicates whether the accelerator is enabled. Defaults to `true`. Valid values: `true`, `false`"
  type        = bool
  default     = true
}

variable "flow_logs_enabled" {
  description = "Indicates whether flow logs are enabled. Defaults to `false`"
  type        = bool
  default     = false
}

variable "flow_logs_s3_bucket" {
  description = "The name of the Amazon S3 bucket for the flow logs. Required if `flow_logs_enabled` is `true`"
  type        = string
  default     = null
}

variable "flow_logs_s3_prefix" {
  description = "The prefix for the location in the Amazon S3 bucket for the flow logs. Required if `flow_logs_enabled` is `true`"
  type        = string
  default     = null
}

### Accelerator - Listener

variable "create_listeners" {
  description = "Controls if listeners should be created (affects only listeners)"
  type        = bool
  default     = true
}

### 

variable "lb_name" {
  description = "name"
  type        = string
  default     = null
}

variable "lb_arn" {
  description = "alb"
  type        = string
  default     = null
}




