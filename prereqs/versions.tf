terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
      environment = "support"
      project     = "tf-eks-helm-automation"
      owner       = "Jaluri@outlook.com"
    }
  }
}
