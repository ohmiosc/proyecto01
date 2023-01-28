output "instance_tags" {
  value = aws_instance.windows-server.tags
}

output "key_name" {
  value = data.aws_key_pair.ec2_key.key_name
}

#output "instance_public_ip" {
#  value = aws_instance.windows-server.public_ip
#}

output "instance_private_ip" {
  value = aws_instance.windows-server.private_ip
}

output "use-ami" {
  value = data.aws_ami.lastet.id
}

output "use-alb" {
  value = tolist(data.aws_alb.alb_internal.security_groups)[0]
  #value = data.aws_alb.alb_internal
}

output "use-alb-https" {
  #value = tolist(data.aws_alb.alb_internal.security_groups)[0]
  value = data.aws_lb_listener.alb_https_arn.id
}
