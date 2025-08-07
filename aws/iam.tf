# EKS Service Role

locals {
  policy_names = [ # Built-in AWS managed policies for EKS
    "AmazonEKSClusterPolicy",
    "AmazonEKSServicePolicy",
    "AmazonEKSWorkerNodePolicy",
    "AmazonEC2ContainerRegistryReadOnly",
    "AutoScalingFullAccess"
  ]
}

data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_service_role" {
  name               = "${var.environment}-eks-service-role"
  description        = "IAM role for EKS cluster service - Managed by Terraform"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json

  tags = {
    Name = "${var.environment}-eks-service-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_service_attachments" {
  for_each = {
    for policy in local.policy_names : policy => policy
  }

  role       = aws_iam_role.eks_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}

# Cluster IAM Outputs

output "eks_service_role_arn" {
  description = "ARN of the EKS service IAM role"
  value       = aws_iam_role.eks_service_role.arn
}

