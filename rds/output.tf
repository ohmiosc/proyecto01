output "subnets_ids" {
  value = data.aws_subnets.private
}

output "vpc_ips" {
  value = data.aws_vpc.selected.cidr_block
}

#output "sub-select" {
#value = data.aws_subnet.private-1
#}