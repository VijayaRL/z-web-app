# Cluster IAM Role
resource "aws_iam_role" "cluster" {
  name               = "${var.project_name}-${var.project_suffix}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_trust.json

  tags = {
    Name    = "${var.project_name}-${var.project_suffix}-cluster-role"
    Project = "${var.project_name}-${var.project_suffix}"
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
    sid    = "ClusterEC2Perms"
    effect = "Allow"
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
    Name    = "${var.project_name}-${var.project_suffix}-node-role"
    Project = "${var.project_name}-${var.project_suffix}"
  }
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
      values = [
        "system:serviceaccount:kube-system:aws-node",
        "system:serviceaccount:kube-system:cluster-autoscaler"
      ]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc_provider.arn]
      type        = "Federated"
    }
  }

  statement {
    sid     = "EKSFargateTrust"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
  }
}

# Node Cluster Autoscaler IAM Policy
data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid    = "ClusterAutoscaler"
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions"
    ]
    resources = ["*"]
  }
}

# ALB Controller Role
resource "aws_iam_role" "data_services_alb_loab_balancer_controller_role" {
  name               = "${var.project_name}-${var.project_suffix}-alb-load-balancer-controller-role"
  assume_role_policy = data.aws_iam_policy_document.eks_trust.json
  tags = {
    Name    = "${var.project_name}-${var.project_suffix}-alb-load-balancer-controller-role"
    Project = "${var.project_name}-${var.project_suffix}"
  }
}

data "aws_iam_policy_document" "eks_trust" {
  statement {
    sid     = "EKSClusterTrust"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc_provider.arn]
      type        = "Federated"
    }
  }
}

# ALB Controller Policy
resource "aws_iam_policy" "data_services_alb_loab_balancer_controller_policy" {
  name = "${var.project_name}-${var.project_suffix}-alb-load-balancer-controller-policy"
  policy = file("${path.module}/alb_load_balancer_policy.json")
  tags = {
    Name    = "${var.project_name}-${var.project_suffix}-alb-load-balancer-controller-policy"
    Project = "${var.project_name}-${var.project_suffix}"
  }
}

# ALB Controller Policy Attachment
resource "aws_iam_role_policy_attachment" "data_services_alb_loab_balancer_controller_policy_attachment" {
  policy_arn = aws_iam_policy.data_services_alb_loab_balancer_controller_policy.arn
  role       = aws_iam_role.data_services_alb_loab_balancer_controller_role.name
}

# EBS CSI Controller Role
resource "aws_iam_role" "data_services_ebs_csi_controller_role" {
  name               = "${var.project_name}-${var.project_suffix}-ebs-csi-controller-role"
  assume_role_policy = data.aws_iam_policy_document.eks_trust_ebs_csi.json
  tags = {
    Name    = "${var.project_name}-${var.project_suffix}-ebs-csi-controller-role"
    Project = "${var.project_name}-${var.project_suffix}"
  }
}

data "aws_iam_policy_document" "eks_trust_ebs_csi" {
  statement {
    sid     = "EKSClusterTrust"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:ebs-csi-controller:ebs-csi-controller-sa"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc_provider.arn]
      type        = "Federated"
    }
  }
}

# EBS CSI Policy Attachment
resource "aws_iam_role_policy_attachment" "data_services_ebs_csi_controller_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.data_services_ebs_csi_controller_role.name
}

# EFS CSI Controller Role
resource "aws_iam_role" "efs_csi_role" {
  name               = "${var.project_name}-${var.project_suffix}-efs-csi-controller-role"
  assume_role_policy = data.aws_iam_policy_document.efs_csi_trust.json

  tags = {
    Name                      = "${var.project_name}-${var.project_suffix}-efs-csi-controller-role"
    Project                   = "${var.project_name}-${var.project_suffix}"
  }
}

# IAM Assume Role Policy Document for EFS CSI Driver
data "aws_iam_policy_document" "efs_csi_trust" {
  statement {
    sid     = "EKSClusterTrust"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:efs-csi-controller:efs-csi-controller-sa"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc_provider.arn]
      type        = "Federated"
    }
  }
}

# EFS CSI Policy Attachment
resource "aws_iam_role_policy_attachment" "efs_csi_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.efs_csi_role.name
}

# Data Role
resource "aws_iam_role" "data_role" {
  name               = "${var.project_name}-${var.project_suffix}-data-role"
  assume_role_policy = data.aws_iam_policy_document.efs_data_trust.json

  tags = {
    Name                      = "${var.project_name}-${var.project_suffix}-data-role"
    Project                   = "${var.project_name}-${var.project_suffix}"
  }
}

# IAM Assume Role Policy Document
data "aws_iam_policy_document" "efs_data_trust" {
  statement {
    sid     = "EKSClusterTrust"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:airflow:airflow", "system:serviceaccount:jupyterhub:jupyterhub"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc_provider.arn]
      type        = "Federated"
    }
  }
}

# Data Policy Attachment
resource "aws_iam_role_policy_attachment" "data_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.data_role.name
}