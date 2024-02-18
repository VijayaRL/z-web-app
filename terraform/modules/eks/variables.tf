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

# EKS Cluster K8s Version
variable "k8s_version" {
  type        = string
  description = "EKS Cluster version"
}

# EKS Cluster Private Subnet ID used by Worker Nodes
variable "private_subnet_id" {
  type        = list(string)
  description = "Private Subnet ids to use and launch the EC2 instances"
}

# EKS Cluster Public Subnet ID used by Worker Nodes
variable "public_subnet_id" {
  type        = list(any)
  description = "Public Subnet ids to use and launch the EC2 instances"
}

# EKS Cluster VPC ID
variable "vpc_id" {
  type        = string
  description = "VPC ID to use for EKS Cluster"
}

# EKS Cluster API Server Endpoint - Private
variable "enable_private_access" {
  type        = bool
  default     = false
  description = "Enable Private Access for EKS Cluster API Server"
}

# EKS Cluster API Server Endpoint - Public
variable "enable_public_access" {
  type        = bool
  default     = true
  description = "Enable Public Access for EKS Cluster API Server"
}

# AWS Region
variable "region" {
  type        = string
  description = "AWS Region to deploy EKS"
}