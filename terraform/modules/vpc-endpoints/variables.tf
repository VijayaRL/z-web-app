# Dev EKS Route Table IDs
variable "eks_route_table_ids" {
  type        = list(string)
  description = "List of route table ids for the peering vpc"
}

# Dev VPC IDs
variable "vpc_id" {
  type        = string
  description = "VPC ID to use"
}

# Project name
variable "project_name" {
  type        = string
  description = "AWS Project Name"
}

# AWS Project Suffix
variable "project_suffix" {
  type        = string
  description = "Project Suffix"
}

# Region
variable "region" {
  type        = string
  description = "Region"
}
