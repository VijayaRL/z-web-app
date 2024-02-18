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

# Subnet ID used by Worker Nodes
variable "private_subnet_id" {
  type        = list(string)
  description = "Private Subnet ids to use and launch the EC2 instances"
}

# NG Instance Type 
variable "instance_type" {
  type        = list(any)
  description = "Cluster Instance Type"
}

# NG Autoscaling Desired Size 
variable "desired_size" {
  type        = string
  description = "Cluster Instance Autoscaling Group Desired Size"
}

#  NG Autoscaling Min Size 
variable "max_size" {
  type        = string
  description = "Cluster Instance Autoscaling Group Max Size"
}

#  NG Autoscaling Max Size 
variable "min_size" {
  type        = string
  description = "Cluster Instance Autoscaling Group Min Size"
}

# NG Volume Size
variable "volume_size" {
  type        = number
  description = "NG Volume Size"
}

# AMI Types 
variable "ami_type" {
  type        = string
  description = " NG AMI Type"
}

# Security Group ID
variable "security_group_id" {
  type        = list(string)
  description = "Security Group ID"
}

# EKS NG Name
variable "node_group_name" {
  type        = string
  description = "EKS NG Name"
}

# EKS NG Label
variable "node_group_type_label" {
  type        = string
  description = "EKS NG Label"
  default     = ""
}

# EKS Node ARN 
variable "node_role_arn" {
  type        = string
  description = "EKS Node ARN"
}

# NG Capacity Type
variable "capacity_type" {
  type        = string
  description = "NG Capacity Type"
}

# NG Taint
variable "taint" {
  type        = list(any)
  description = "NG Taint"
  default     = []
}

# Associate Public IP address
variable associate_public_ip_address {
  type        = bool
  default     = true
  description = "Associate Public IP address"
}