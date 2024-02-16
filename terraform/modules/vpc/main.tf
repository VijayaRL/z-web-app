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

# Public Subnet
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_cidr_subnet_a
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"

  tags = {
    Name                                                              = "${var.project_name}-${var.project_suffix}-public-subnet-a"
    Project                                                           = "${var.project_name}-${var.project_suffix}"
    Tier                                                              = "Public"
    AZ                                                                = "${var.region}a"
    "kubernetes.io/cluster/${var.project_name}-${var.project_suffix}" = "shared"
    "kubernetes.io/role/elb"                                          = "1"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_cidr_subnet_b
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}b"

  tags = {
    Name                                                              = "${var.project_name}-${var.project_suffix}-public-subnet-b"
    Project                                                           = "${var.project_name}-${var.project_suffix}"
    Tier                                                              = "Public"
    AZ                                                                = "${var.region}b"
    "kubernetes.io/cluster/${var.project_name}-${var.project_suffix}" = "shared"
    "kubernetes.io/role/elb"                                          = "1"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet_c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_cidr_subnet_c
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}c"

  tags = {
    Name                                                              = "${var.project_name}-${var.project_suffix}-public-subnet-c"
    Project                                                           = "${var.project_name}-${var.project_suffix}"
    Tier                                                              = "Public"
    AZ                                                                = "${var.region}c"
    "kubernetes.io/cluster/${var.project_name}-${var.project_suffix}" = "shared"
    "kubernetes.io/role/elb"                                          = "1"
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

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name                                                              = "${var.project_name}-${var.project_suffix}-public-rt"
    Project                                                           = "${var.project_name}-${var.project_suffix}"
    "kubernetes.io/cluster/${var.project_name}-${var.project_suffix}" = "shared"
    "kubernetes.io/role/elb"                                          = "1"
  }
}

# Public Route Table association with Public Subnet
resource "aws_route_table_association" "public_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

# Public Route Table association with Public Subnet
resource "aws_route_table_association" "public_association_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

# Public Route Table association with Public Subnet
resource "aws_route_table_association" "public_association_c" {
  subnet_id      = aws_subnet.public_subnet_c.id
  route_table_id = aws_route_table.public_rt.id
}