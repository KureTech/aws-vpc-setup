output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.vpcname_vpc.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [for subnet in aws_subnet.public_subnet : subnet.id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [for subnet in aws_subnet.private_subnet : subnet.id]
}

output "nat_gateway_ids" {
  value = [for nat in aws_nat_gateway.nat_gateway : nat.id]
}
output "flow_log_group" {
  description = "CloudWatch Flow Log Group"
  value       = aws_flow_log.vpc_flow_log.log_destination
}

output "vpc_security_group_id" {
  value = aws_security_group.vpc_sg.id
}