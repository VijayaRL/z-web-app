# Get AWS Account details
data "aws_caller_identity" "current" {}

# EKS Cluster
resource "aws_eks_cluster" "eks" {
  name                      = "${var.project_name}-${var.project_suffix}"
  role_arn                  = aws_iam_role.cluster.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  version                   = var.k8s_version

  vpc_config {
    security_group_ids      = [aws_security_group.cluster.id]
    subnet_ids              = var.public_subnet_id
    endpoint_private_access = var.enable_private_access
    endpoint_public_access  = var.enable_public_access
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster-AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.cluster-clusterec2policy
  ]

  tags = {
    Name       = "${var.project_name}-${var.project_suffix}"
    Project    = "${var.project_name}-${var.project_suffix}"
  }
}