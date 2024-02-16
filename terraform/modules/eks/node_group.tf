# EKS On-Demand Private Node Group launch template
resource "aws_launch_template" "ondemand_services" {
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.ondemand_services_disk_size
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  ebs_optimized = true

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = [aws_security_group.workers.id]
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "${var.project_name}-${var.project_suffix}-eks-ec2"
      Project = "${var.project_name}-${var.project_suffix}"
    }
  }
}

# EKS Cluster Private On-Demand Node Group
resource "aws_eks_node_group" "ondemand_services" {
  cluster_name           = aws_eks_cluster.eks.name
  node_group_name_prefix = "ondemand-services-"
  node_role_arn          = aws_iam_role.node.arn
  subnet_ids             = var.public_subnet_id
  ami_type               = "AL2_x86_64"
  capacity_type          = "ON_DEMAND"
  instance_types         = var.ondemand_services_instance

  scaling_config {
    desired_size = var.ondemand_services_desired_size
    max_size     = var.ondemand_services_max_size
    min_size     = var.ondemand_services_min_size
  }

  launch_template {
    id      = aws_launch_template.ondemand_services.id
    version = aws_launch_template.ondemand_services.latest_version
  }

  labels = {
    "group"  = "ondemand-services"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config.0.desired_size]
  }

  tags = {
    Name    = "${var.project_name}-${var.project_suffix}-eks-ec2"
    Project = "${var.project_name}-${var.project_suffix}"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnlyAccess,
    aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryFullAccess,
    aws_iam_role_policy_attachment.node-autoscalingpolicyattachment,
    aws_eks_cluster.eks
  ]
}