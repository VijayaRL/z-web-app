# Get AWS Account details
data "aws_caller_identity" "current" {}

# VPC 
module "vpc" {
    source                      = "../modules/vpc"
    project_name                = var.project_name
    project_suffix              = var.project_suffix
    vpc_cidr                    = var.vpc_cidr
    region                      = var.region
    public_cidrs                = var.public_cidrs
    private_cidrs               = var.private_cidrs
}

# VPC endpoints 
module "vpc_endpoints" {
  source              = "../modules/vpc-endpoints"
  project_name        = var.project_name
  project_suffix      = var.project_suffix
  eks_route_table_ids = [module.vpc.private_route_table_id, module.vpc.public_route_table_id]
  vpc_id              = module.vpc.vpc_id
  region              = var.region
  depends_on          = [module.vpc]
}

# EKS Cluster 
module "eks" {
    source                     = "../modules/eks"
    project_name               = var.project_name
    project_suffix             = var.project_suffix
    region                     = var.region
    vpc_id                     = module.vpc.vpc_id
    private_subnet_id          = module.vpc.private_subnet_id
    public_subnet_id           = module.vpc.public_subnet_id
    k8s_version                = var.k8s_version
    depends_on                 = [module.vpc]
}

# EKS EC2 OnDemand NG
module "ec2_ng_ondemand_m6a_xlarge" {
  source                = "../modules/eks-ec2-node-group"
  project_name          = var.project_name
  project_suffix        = var.project_suffix
  node_group_name       = "ondemand-m6a-xlarge"
  private_subnet_id     = module.vpc.private_subnet_id
  security_group_id     = [module.eks.worker_sg]
  instance_type         = ["m6a.xlarge"]
  ami_type              = "AL2_x86_64"
  capacity_type         = "ON_DEMAND"
  desired_size          = "1"
  min_size              = "1"
  max_size              = "2"
  volume_size           = "20"
  node_role_arn         = module.eks.worker_iam_arn
  node_group_type_label = "ondemand-m6a-xlarge"
  depends_on            = [module.vpc, module.eks]
}