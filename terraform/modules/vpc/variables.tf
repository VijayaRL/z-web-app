# AWS Project Name
variable "project_name" {
  type        = string
  description = "AWS Project Name"
}

# AWS Project Suffix
variable "project_suffix" {
  type        = string
  description = "Project Suffix"
}

# AWS VPC CIDR
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR range"
}

# AWS Region 
variable "region" {
  type        = string
  description = "AWS Region"
}

# AWS Public CIDRs
variable "public_cidrs" {
  type        = list(any)
  description = "Public CIDR range"
}

# AWS Private CIDRs
variable "private_cidrs" {
  type        = list(any)
  description = "Private CIDR range"
}