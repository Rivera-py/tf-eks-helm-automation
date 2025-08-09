# EKS Cluster Requires Resources

## EKS Encryption Key

data "aws_iam_policy_document" "eks_secrets_kms" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}

resource "aws_kms_key" "eks_secrets" {
  description         = "KMS key for EKS secrets encryption - Managed by Terraform"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.eks_secrets_kms.json

  tags = {
    Name = "${var.environment}-eks-secrets-kms"
  }
}


# EKS Cluster Configuration

resource "aws_eks_cluster" "cluster" {
  name                      = "eks-cluster-${var.environment}"
  role_arn                  = aws_iam_role.eks_service_role.arn
  enabled_cluster_log_types = var.control_plane_log_types
  version                   = var.kubernetes_version

  vpc_config {
    public_access_cidrs = [var.allowed_public_ingress_ip]
    subnet_ids          = aws_subnet.eks_private[*].id
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.eks_secrets.arn
    }
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.eks_service_cidr
  }

  upgrade_policy {
    support_type = "STANDARD"
  }

  depends_on = [
    aws_cloudwatch_log_group.eks_control_plane
  ]
}

resource "aws_eks_access_policy_association" "admin_user_access" {
  cluster_name  = aws_eks_cluster.cluster.name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.admin_access_username}"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
