################################################
# VPC                                          #
################################################
# AWS VPC ID
output vpc_id {
  value = module.vpc.vpc_id
}

# AWS VPC CIDR
output vpc_cidr {
  value = module.vpc.vpc_cidr
}

# Public Route Table ID
output public_route_table_id {
  value = module.vpc.public_route_table_id
}

# Internet Gateway ID
output internet_gateway_id {
  value = module.vpc.internet_gateway_id
}

# Subnet ID AZ-A
output public_subnet_id_a {
  value = module.vpc.public_subnet_id_a
}

# Subnet ID AZ-B
output public_subnet_id_b {
  value = module.vpc.public_subnet_id_b
}

# Subnet ID AZ-C
output public_subnet_id_c {
  value = module.vpc.public_subnet_id_c
}

################################################
# EKS                                          #
################################################
# EKS Cluster K8s Version
output eks_version {
  value       = module.eks.eks_version
}

# EKS Cluster ARN
output eks_arn {
  value       = module.eks.eks_arn
}

# EKS Cluster Endpoint
output eks_endpoint {
  value       = module.eks.eks_endpoint
}

# EKS Cluster IAM Role ARN
output cluster_iam_arn {
  value       = module.eks.cluster_iam_arn
}

# EKS Cluster Security Group
output cluster_sg {
  value       = module.eks.cluster_sg
}

# EKS Worker Security Group
output worker_sg {
  value       = module.eks.worker_sg
}

# EKS Cluster Worker IAM ARN
output worker_iam_arn {
  value       = module.eks.worker_iam_arn
}

# EKS Command 
output eks_command {
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${var.project_name}-${var.project_suffix}"
}

# EKS Cluster Name 
output cluster_name {
  value       = module.eks.cluster_name
}

# EKS Node Role name 
output eks_node_role {
  value       = module.eks.eks_node_role
  description = "EKS Node Role Name"
}

# OIDC Provider Url
output oidc_provider_url {
  description = "oidc_provider_url"
  value       = module.eks.oidc_provider_url
}

# OIDC Provider Arn
output oidc_provider_arn {
  description = "oidc_provider_arn"
  value       = module.eks.oidc_provider_arn
}

################################################
# AWS                                          #
################################################
# AWS Account ID
output aws_account_id {
    value = data.aws_caller_identity.current.account_id
}