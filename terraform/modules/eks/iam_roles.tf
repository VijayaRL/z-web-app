# Cluster IAM Role
resource "aws_iam_role" "cluster" {
  name               = "${var.project_name}-${var.project_suffix}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_trust.json

  tags = {
    Name       = "${var.project_name}-${var.project_suffix}-cluster-role"
    Project    = "${var.project_name}-${var.project_suffix}"
  }
}

# Cluster IAM Policy attachment
resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# Cluster IAM Policy attachment
resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster.name
}

# Cluster IAM Policy attachment
resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

# Cluster EC2 policy
resource "aws_iam_policy" "cluster_ec2_policy" {
  name        = "${var.project_name}-${var.project_suffix}-cluster-ec2-policy"
  description = "EKS Cluster EC2 policy ${var.project_name}"
  policy      = data.aws_iam_policy_document.cluster_ec2_policy.json
}

# Cluster EC2 IAM Policy
data "aws_iam_policy_document" "cluster_ec2_policy" {
  statement {
    sid     = "ClusterEC2Perms"
    effect  = "Allow"
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeInternetGateways"
      ]
    resources = ["*"]
    }
  }

# Cluster EC2 IAM Policy attachment
resource "aws_iam_role_policy_attachment" "cluster-clusterec2policy" {
  policy_arn = aws_iam_policy.cluster_ec2_policy.arn
  role       = aws_iam_role.cluster.name
}

# Node IAM Role
resource "aws_iam_role" "node" {
  name               = "${var.project_name}-${var.project_suffix}-node-role"
  assume_role_policy = data.aws_iam_policy_document.node_trust.json

  tags = {
    Name       = "${var.project_name}-${var.project_suffix}-node-role"
    Project    = "${var.project_name}-${var.project_suffix}"
  }
}

# Node EC2 IAM Policy
data "aws_iam_policy_document" "node_ec2_policy" {
  statement {
    sid     = "NodeEC2Perms"
    effect  = "Allow"
    actions = [
      "s3:*"
      ]
    resources = ["*"]
    }
  }

# Node EC2 policy
resource "aws_iam_policy" "node_ec2_policy" {
  name        = "${var.project_name}-${var.project_suffix}-node-ec2-policy"
  description = "EKS Node EC2 policy ${var.project_name}"
  policy      = data.aws_iam_policy_document.node_ec2_policy.json
}

# Node EC2 IAM Policy attachment
resource "aws_iam_role_policy_attachment" "node-nodeec2policy" {
  policy_arn = aws_iam_policy.node_ec2_policy.arn
  role       = aws_iam_role.node.name
}

# Node IAM Policy attachment
resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

# Node IAM Policy attachment
resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

# Node IAM Policy attachment
resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnlyAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

# Node IAM Policy attachment
resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  role       = aws_iam_role.node.name
}

# Node IAM Policy attachment
resource "aws_iam_role_policy_attachment" "node-CloudWatchAgentServerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.node.name
}

# Node Autoscaler policy
resource "aws_iam_policy" "node_autoscaling" {
  name        = "${var.project_name}-${var.project_suffix}-eks-node-autoscaling"
  description = "EKS worker node autoscaling policy for cluster ${var.project_name}"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

# Node IAM Policy attachment
resource "aws_iam_role_policy_attachment" "node-autoscalingpolicyattachment" {
  policy_arn = aws_iam_policy.node_autoscaling.arn
  role       = aws_iam_role.node.name
}

# Cluster IAM Policy
data "aws_iam_policy_document" "cluster_trust" {
  statement {
    sid     = "EKSClusterTrust"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

# Node IAM Policy
data "aws_iam_policy_document" "node_trust" {
  statement {
    sid     = "EKSNodeTrust"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub"
      values   = [
                "system:serviceaccount:kube-system:aws-node",
                "system:serviceaccount:kube-system:cluster-autoscaler"
                ]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc_provider.arn]
      type        = "Federated"
    }
  }
}

# Node Cluster Autoscaler IAM Policy
data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid     = "ClusterAutoscaler"
    effect  = "Allow"
    actions = [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
            ]
    resources = ["*"]
    }
  }