# VPC ID
output vpc_id {
  value = aws_vpc.vpc.id
}

# VPC CIDR
output vpc_cidr {
  value = var.vpc_cidr
}

# Public Route Table ID
output public_route_table_id {
  value = aws_route_table.public_rt.id
}

# Internet Gateway ID
output internet_gateway_id {
  value = aws_internet_gateway.internet_gateway.id
}

# Public Subnet ID in AZ - A
output "public_subnet_id_a" {
  value = aws_subnet.public_subnet_a.id
}

# Public Subnet ID in AZ - B
output "public_subnet_id_b" {
  value = aws_subnet.public_subnet_b.id
}

# Public Subnet ID in AZ - C
output "public_subnet_id_c" {
  value = aws_subnet.public_subnet_c.id
}