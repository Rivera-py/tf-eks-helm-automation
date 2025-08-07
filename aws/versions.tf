terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }

  backend "s3" {
    encrypt      = true
    use_lockfile = true
    bucket       = "s3-tf-eks-helm-automation-state-299858989921-eu-west-2" # Created by prereqs
    region       = "eu-west-2"
    key          = "aws/terraform.tfstate"
  }
}

provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
      environment = var.environment
      project     = "tf-eks-helm-automation"
      owner       = "Jaluri@outlook.com"
    }
  }
}
