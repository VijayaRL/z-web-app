# EKS Node Group Launch Template
resource "aws_launch_template" "ng_launch_template" {
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.volume_size
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  ebs_optimized = true

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    delete_on_termination       = true
    security_groups             = var.security_group_id
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "${var.project_name}-${var.project_suffix}-${var.node_group_name}"
      Project = "${var.project_name}-${var.project_suffix}"
    }
  }
}

# EKS Node Group
resource "aws_eks_node_group" "ng" {
  cluster_name           = "${var.project_name}-${var.project_suffix}"
  node_group_name_prefix = "${var.node_group_name}-"
  node_role_arn          = var.node_role_arn
  subnet_ids             = var.private_subnet_id
  ami_type               = var.ami_type
  capacity_type          = var.capacity_type
  instance_types         = var.instance_type

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  launch_template {
    id      = aws_launch_template.ng_launch_template.id
    version = aws_launch_template.ng_launch_template.latest_version
  }

  labels = {
    "group" = var.node_group_type_label == "" ? var.node_group_name : var.node_group_type_label
    "type"  = var.node_group_type_label == "" ? var.node_group_name : var.node_group_type_label
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config.0.desired_size]
  }

  tags = {
    Name    = "${var.project_name}-${var.project_suffix}-ng"
    Project = "${var.project_name}-${var.project_suffix}"
  }

  dynamic "taint" {
    for_each = var.taint
    content {
      key    = taint.value["key"]
      value  = taint.value["value"]
      effect = "NO_SCHEDULE"
    }
  }
}