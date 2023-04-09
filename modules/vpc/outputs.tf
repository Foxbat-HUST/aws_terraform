output "vpc_id" {
  description = "vpc id"
  value       = aws_vpc.vpc.id
}

output "public_subnets_data" {
  description = "public subnet data (id and cidr)"
  value = [for i in range(length(aws_subnet.public_subnets)) : {
    id   = element(aws_subnet.public_subnets, i).id
    cidr = element(aws_subnet.public_subnets, i).cidr_block
  }]
}


output "private_subnets_data" {
  description = "private subnet data (id and cidr)"
  value = [for i in range(length(aws_subnet.public_subnets)) : {
    id   = element(aws_subnet.private_subnets, i).id
    cidr = element(aws_subnet.private_subnets, i).cidr_block
  }]
}

output "default_route_table_id" {
  description = "default route table id"
  value       = aws_vpc.vpc.default_route_table_id
}

output "default_network_acl" {
  description = "default network acl id"
  value       = aws_vpc.vpc.default_network_acl_id
}
