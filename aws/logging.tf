# Shared Logging Resources

data "aws_iam_policy_document" "cloudwatch_logs_kms" {
  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.region}.amazonaws.com"]
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
  statement {
    sid    = "AllowAccount"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }
}

resource "aws_kms_key" "cloudwatch_logs" {
  description         = "KMS key for cloudwatch log group encryption - Managed by Terraform"
  enable_key_rotation = true

  policy = data.aws_iam_policy_document.cloudwatch_logs_kms.json

  tags = {
    Name = "${var.environment}-cloudwatch-logs-kms"
  }
}

# VPC Flow Logs resources

data "aws_iam_policy_document" "vpc_flow_logs_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "vpc_flow_logs" {
  name               = "${var.environment}-eks-vpc-flow-logs-role"
  description        = "IAM role for VPC Flow Logs to publish to CloudWatch Logs - Managed by Terraform"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_assume_role.json

  tags = {
    Name = "${var.environment}-eks-vpc-flow-logs-role"
  }
}

data "aws_iam_policy_document" "vpc_flow_logs_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = [
      aws_cloudwatch_log_group.eks_vpc_flow_logs.arn,
      "${aws_cloudwatch_log_group.eks_vpc_flow_logs.arn}:*"
    ]
  }
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  name   = "${var.environment}-eks-vpc-flow-logs-policy"
  role   = aws_iam_role.vpc_flow_logs.id
  policy = data.aws_iam_policy_document.vpc_flow_logs_policy.json
}

resource "aws_cloudwatch_log_group" "eks_vpc_flow_logs" {
  name              = "/aws/vpc/${var.environment}-eks-flow-logs"
  retention_in_days = 14
  kms_key_id        = aws_kms_key.cloudwatch_logs.arn

  tags = {
    Name = "${var.environment}-eks-vpc-flow-logs"
  }
}

resource "aws_flow_log" "eks_vpc" {
  vpc_id               = aws_vpc.eks.id
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.eks_vpc_flow_logs.arn
  iam_role_arn         = aws_iam_role.vpc_flow_logs.arn
  traffic_type         = "ALL"

  tags = {
    Name = "${var.environment}-eks-vpc-flow-logs"
  }
}

# Kubernetes API Logging

resource "aws_cloudwatch_log_group" "eks_control_plane" {
  name              = "/aws/eks/${var.environment}/cluster"
  retention_in_days = 14
  kms_key_id        = aws_kms_key.cloudwatch_logs.arn

  tags = {
    Name = "${var.environment}-eks-control-plane-logs"
  }
}

# Note: To enable EKS control plane logging, set 'enabled_cluster_log_types' in your aws_eks_cluster resource to:
# ["api", "audit", "authenticator", "controllerManager", "scheduler"]
# AWS will automatically send logs to this log group if it exists and the EKS service role has the correct permissions.

