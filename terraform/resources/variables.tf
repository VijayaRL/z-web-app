# Project name
variable project_name {
  type = string
  description = "AWS Project Name"
}

# AWS Project Suffix
variable project_suffix {
  type        = string
  description = "Project Suffix"
}

################################################
# VPC                                          #
################################################
# AWS VPC CIDR
variable vpc_cidr {
  type = string
  description = "VPC CIDR range"
}

# AWS VPC Public CIDRs
variable "public_cidrs" {
  type        = list(any)
  description = "Public CIDR range"
}

# AWS VPC Private CIDRs
variable "private_cidrs" {
  type        = list(any)
  description = "Private CIDR range"
}

################################################
# EKS                                          #
################################################
# EKS Cluster K8s Version
variable k8s_version {
  type        = string
  description = "Kubernetes Version"
}

# AWS Region
variable region {
  type        = string
  description = "AWS Region to deploy EKS"
}