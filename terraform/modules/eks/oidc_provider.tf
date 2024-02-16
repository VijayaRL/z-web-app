# TLS certificate of the cluster
data "tls_certificate" "tls_cert" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

# OpenID provider 
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.tls_cert.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer

  tags = {
    Name       = "${var.project_name}-${var.project_suffix}"
    Project    = "${var.project_name}-${var.project_suffix}"
  }
}