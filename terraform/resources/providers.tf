# Terraform AWS Provider Version
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 2.2"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}