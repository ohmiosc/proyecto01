output "nat_ngws_1" {
  value = data.aws_nat_gateway.ngw[*].public_ip
}

output "alb" {
  value = data.aws_alb.alb_internal.arn
}
