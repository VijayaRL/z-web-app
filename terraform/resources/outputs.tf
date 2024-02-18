# AWS VPC ID
output "vpc_id" {
  value = module.vpc.vpc_id
}

# AWS VPC CIDR
output "vpc_cidr" {
  value = module.vpc.vpc_cidr
}

# AWS VPC Public Subnet ID
output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}

# AWS VPC Private Subnet ID
output "private_subnet_id" {
  value = module.vpc.private_subnet_id
}

# Public Subnet ID in AZ - A
output "public_subnet_id_a" {
  value = module.vpc.public_subnet_id_a
}

# Public Subnet ID in AZ - B
output "public_subnet_id_b" {
  value = module.vpc.public_subnet_id_b
}

# Private Subnet ID in AZ - A
output "private_subnet_id_a" {
  value = module.vpc.private_subnet_id_a
}

# Private Subnet ID in AZ - B
output "private_subnet_id_b" {
  value = module.vpc.private_subnet_id_b
}

# Public Route Table ID
output "public_route_table_id" {
  value = module.vpc.public_route_table_id
}

# Private Route Table ID
output "private_route_table_id" {
  value = module.vpc.private_route_table_id
}

# Internet Gateway ID
output "internet_gateway_id" {
  value = module.vpc.internet_gateway_id
}

# NAT Gateway ID 
output "nat_gateway_id" {
  value = module.vpc.nat_gateway_id
}