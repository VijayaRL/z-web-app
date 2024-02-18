data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

# Private Subnet (AZ - A)
data "aws_subnet" "private_subnet_a" {
  filter {
    name   = "tag:Project"
    values = ["${var.project_name}-${var.project_suffix}"]
  }

  filter {
    name   = "tag:Tier"
    values = ["Private"]
  }

  filter {
    name   = "tag:AZ"
    values = ["${var.region}a"]
  }

  depends_on = [aws_subnet.private_subnet]
}

# Private Subnet (AZ - B)
data "aws_subnet" "private_subnet_b" {
  filter {
    name   = "tag:Project"
    values = ["${var.project_name}-${var.project_suffix}"]
  }

  filter {
    name   = "tag:Tier"
    values = ["Private"]
  }

  filter {
    name   = "tag:AZ"
    values = ["${var.region}b"]
  }

  depends_on = [aws_subnet.private_subnet]
}

# Public Subnet (AZ - A)
data "aws_subnet" "public_subnet_a" {
  filter {
    name   = "tag:Project"
    values = ["${var.project_name}-${var.project_suffix}"]
  }

  filter {
    name   = "tag:Tier"
    values = ["Public"]
  }

  filter {
    name   = "tag:AZ"
    values = ["${var.region}a"]
  }

  depends_on = [aws_subnet.public_subnet]
}

# Public Subnet (AZ - B)
data "aws_subnet" "public_subnet_b" {
  filter {
    name   = "tag:Project"
    values = ["${var.project_name}-${var.project_suffix}"]
  }

  filter {
    name   = "tag:Tier"
    values = ["Public"]
  }

  filter {
    name   = "tag:AZ"
    values = ["${var.region}b"]
  }

  depends_on = [aws_subnet.public_subnet]
}

# VPC Declaration
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name                                                              = "${var.project_name}-${var.project_suffix}-vpc"
    Project                                                           = "${var.project_name}-${var.project_suffix}"
    "kubernetes.io/cluster/${var.project_name}-${var.project_suffix}" = "shared"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                                                              = "${var.project_name}-${var.project_suffix}-public-subnet-${count.index + 1}"
    Project                                                           = "${var.project_name}-${var.project_suffix}"
    Tier                                                              = "Public"
    AZ                                                                = data.aws_availability_zones.available.names[count.index]
    "kubernetes.io/cluster/${var.project_name}-${var.project_suffix}" = "shared"
    "kubernetes.io/role/elb"                                          = "1"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                                                              = "${var.project_name}-${var.project_suffix}-private-subnet-${count.index + 1}"
    Project                                                           = "${var.project_name}-${var.project_suffix}"
    Tier                                                              = "Private"
    AZ                                                                = data.aws_availability_zones.available.names[count.index]
    "kubernetes.io/cluster/${var.project_name}-${var.project_suffix}" = "shared"
    "kubernetes.io/role/internal-elb"                                 = "1"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project_name}-${var.project_suffix}-igw"
    Project = "${var.project_name}-${var.project_suffix}"
  }
}

# Public Route Tables
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name                                                              = "${var.project_name}-${var.project_suffix}-public-rt"
    Project                                                           = "${var.project_name}-${var.project_suffix}"
    "kubernetes.io/cluster/${var.project_name}-${var.project_suffix}" = "shared"
    "kubernetes.io/role/elb"                                          = "1"
  }
}

# Public Route Table association with Public Subnet
resource "aws_route_table_association" "public_association" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
  route_table_id = aws_route_table.public_rt.id
}

# Elastic IP
resource "aws_eip" "nat_eip" {
  vpc = true

  tags = {
    Name    = "${var.project_name}-${var.project_suffix}-eip"
    Project = "${var.project_name}-${var.project_suffix}"
  }

}

# NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id
  depends_on    = [aws_internet_gateway.internet_gateway]

  tags = {
    Name    = "${var.project_name}-${var.project_suffix}-nat"
    Project = "${var.project_name}-${var.project_suffix}"
  }
}

# Private Route Tables
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name                                                              = "${var.project_name}-${var.project_suffix}-private-rt"
    Project                                                           = "${var.project_name}-${var.project_suffix}"
    "kubernetes.io/cluster/${var.project_name}-${var.project_suffix}" = "shared"
    "kubernetes.io/role/internal-elb"                                 = "1"
  }
}

# Private Route Table association with Private Subnet
resource "aws_route_table_association" "private_association" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# IGW Gateway Route 
resource "aws_route" "eks_igw_gtw" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

# NAT Gateway Route 
resource "aws_route" "eks_nat_gtw" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}