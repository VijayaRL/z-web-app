resource "aws_vpc_endpoint" "vpc_endpoint_s3" {
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  vpc_id            = var.vpc_id
  route_table_ids   = var.eks_route_table_ids

  tags = {
    Name    = "${var.project_name}-${var.project_suffix}-vpc-endpoint-s3"
    Project = "${var.project_name}-${var.project_suffix}"
  }
}
