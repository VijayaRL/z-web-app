# Get AWS Account details
data "aws_caller_identity" "current" {}

# VPC 
module "vpc" {
    source                      = "../modules/vpc"
    project_name                = var.project_name
    project_suffix              = var.project_suffix
    vpc_cidr                    = var.vpc_cidr
    region                      = var.region
    public_cidr_subnet_a        = var.public_cidr_subnet_a
    public_cidr_subnet_b        = var.public_cidr_subnet_b
    public_cidr_subnet_c        = var.public_cidr_subnet_c
}

# EKS Cluster 
module "eks" {
    source                                      = "../modules/eks"
    project_name                                = var.project_name
    project_suffix                              = var.project_suffix
    region                                      = var.region
    vpc_id                                      = module.vpc.vpc_id
    public_subnet_id                            = [module.vpc.public_subnet_id_a, module.vpc.public_subnet_id_b, module.vpc.public_subnet_id_c]
    k8s_version                                 = var.k8s_version
    ondemand_services_instance                  = var.ondemand_services_instance
    ondemand_services_desired_size              = var.ondemand_services_desired_size
    ondemand_services_max_size                  = var.ondemand_services_max_size
    ondemand_services_min_size                  = var.ondemand_services_min_size
    ondemand_services_disk_size                 = var.ondemand_services_disk_size
    depends_on                                  = [module.vpc]
}