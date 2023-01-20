output "alb_id" {
  value = module.alb.alb_id
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "alb_zone_id" {
  value = module.alb.alb_zone_id
}

output "https_alb_listener_rule_id" {
  value = module.alb.https_alb_listener_rule_id
}

output "https_alb_listener_rule_arn" {
  value = module.alb.https_alb_listener_rule_arn
}

output "security_group_id" {
  value = module.alb.security_group_id
}

output "security_group_vpc_id" {
  value = module.alb.security_group_vpc_id
}

output "security_group_owner_id" {
  value = module.alb.security_group_owner_id
}

output "security_group_name" {
  value = module.alb.security_group_name
}

output "security_group_description" {
  value = module.alb.security_group_description
}

output "security_group_ingress" {
  value = module.alb.security_group_ingress
}

output "security_group_egress" {
  value = module.alb.security_group_egress
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}