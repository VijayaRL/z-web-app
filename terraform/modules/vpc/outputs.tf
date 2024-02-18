# VPC ID
output "vpc_id" {
  value = aws_vpc.vpc.id
}

# Public Subnet ID
output "public_subnet_id" {
  value = aws_subnet.public_subnet.*.id
}

# Public Subnet ID in AZ - A
output "public_subnet_id_a" {
  value = data.aws_subnet.public_subnet_a.id
}

# Public Subnet ID in AZ - B
output "public_subnet_id_b" {
  value = data.aws_subnet.public_subnet_b.id
}

# Private Subnet ID
output "private_subnet_id" {
  value = aws_subnet.private_subnet.*.id
}

# Private Subnet ID in AZ - A
output "private_subnet_id_a" {
  value = data.aws_subnet.private_subnet_a.id
}

# Private Subnet ID in AZ - B
output "private_subnet_id_b" {
  value = data.aws_subnet.private_subnet_b.id
}

# VPC CIDR
output "vpc_cidr" {
  value = var.vpc_cidr
}

# Public Route Table ID
output "public_route_table_id" {
  value = aws_route_table.public_rt.id
}

# Private Route Table ID
output "private_route_table_id" {
  value = aws_route_table.private_rt.id
}

# Internet Gateway ID
output "internet_gateway_id" {
  value = aws_internet_gateway.internet_gateway.id
}

# NAT Gateway ID 
output "nat_gateway_id" {
  value = aws_nat_gateway.nat_gateway.id
}