output "vpc_id" {
    description = "vpc id"
    value = aws_vpc.vpc.id
}

output "public_subnet_id" {
  description = "public subject ids"
  value = aws_subnet.public_subnet.id
}

output "private_subnet_ids" {
    description = "private subnet ids"
    value = aws_subnet.private_subnets[*].id
}

output "default_route_table_id" {
  description = "default route table id"
  value = aws_vpc.vpc.default_route_table_id
}

output "default_network_acl" {
    description = "default network acl id"
    value = aws_vpc.vpc.default_network_acl_id
}