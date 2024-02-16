# EKS Cluster Version
output eks_version {
  value       = aws_eks_cluster.eks.version
  description = "EKS version"
}

# EKS Cluster ARN
output eks_arn {
  value       = aws_eks_cluster.eks.arn
  description = "ARN for the EKS cluster."
}

# EKS Cluster Endpoint
output eks_endpoint {
  value       = aws_eks_cluster.eks.endpoint
  description = "EKS api server endpoint."
}

# EKS Cluster IAM ARN
output cluster_iam_arn {
  value       = aws_iam_role.cluster.arn
  description = "ARN for the cluster master nodes IAM role."
}

# EKS Cluster Security Group
output cluster_sg {
  value       = aws_security_group.cluster.id
  description = "Security group id for cluster master nodes."
}

# EKS Workers Security Group
output worker_sg {
  value       = aws_security_group.workers.id
  description = "Security group id for cluster workers nodes."
}

# EKS Node Role name 
output eks_node_role {
  value       = aws_iam_role.node.name
  description = "EKS Node Role Name"
}

# EKS Cluster Worker IAM ARN
output worker_iam_arn {
  value       = aws_iam_role.node.arn
  description = "ARN for the cluster worker nodes IAM role."
}

# EKS Cluster name 
output cluster_name {
  description = "EKS Cluster Name"
  value       = aws_eks_cluster.eks.name
}

# OIDC Provider Url
output oidc_provider_url {
  description = "oidc_provider_url"
  value       = aws_iam_openid_connect_provider.oidc_provider.url
}

# OIDC Provider Arn
output oidc_provider_arn {
  description = "oidc_provider_arn"
  value       = aws_iam_openid_connect_provider.oidc_provider.arn
}