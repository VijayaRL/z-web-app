# EKS Cluster Security Group
resource "aws_security_group" "cluster" {
  name        = "${var.project_name}-${var.project_suffix}-cluster-sg"
  description = "Cluster communication with Worker Nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow cluster egress access to the Internet"
  }

  tags = {
    Name                                        = "${var.project_name}-${var.project_suffix}-cluster-sg"
    Project                                     = "${var.project_name}-${var.project_suffix}"
    "kubernetes.io/cluster/${var.project_name}" = "owned"
  }
}

# Cluster Security Group Rule
resource "aws_security_group_rule" "cluster_ingress_node_https" {
  description              = "Allow pods to communicate with the Cluster API Server"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.workers.id
  type                     = "ingress"
  protocol                 = "TCP"
  from_port                = 443
  to_port                  = 443
}

# EKS Workers Security Group
resource "aws_security_group" "workers" {
  name        = "${var.project_name}-${var.project_suffix}-workers-sg"
  description = "Security group for all nodes in the cluster."
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow workers egress access to the Internet"
  }

  tags = {
    Name                                        = "${var.project_name}-${var.project_suffix}-workers-sg"
    Project                                     = "${var.project_name}-${var.project_suffix}"
    "kubernetes.io/cluster/${var.project_name}" = "owned"
    }
}

# Workers Security Group Rule
resource "aws_security_group_rule" "workers_ingress_self" {
  description              = "Allow node to communicate with each other"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.workers.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
}

# Workers Security Group Rule
resource "aws_security_group_rule" "workers_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.cluster.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 1025
  to_port                  = 65535
}

# Workers Security Group Rule
resource "aws_security_group_rule" "workers_ingress_cluster_kubelet" {
  description              = "Allow workers Kubelets to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.cluster.id
  from_port                = 10250
  to_port                  = 10250
  type                     = "ingress"
}

# Workers Security Group Rule
resource "aws_security_group_rule" "workers_ingress_cluster_https" {
  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.cluster.id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

# Workers Security Group Rule
resource "aws_security_group_rule" "workers_ingress_cluster_primary" {
  description              = "Allow pods running on workers to receive communication from cluster primary security group"
  protocol                 = "all"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.cluster.id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

# Workers Security Group Rule
resource "aws_security_group_rule" "cluster_primary_ingress_workers" {
  description              = "Allow pods running on workers to send communication to cluster primary security group"
  protocol                 = "all"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.workers.id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}