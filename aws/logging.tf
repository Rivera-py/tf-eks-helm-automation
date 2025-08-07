# VPC Flow Logs resources

resource "aws_cloudwatch_log_group" "eks_vpc_flow_logs" {
  name              = "/aws/vpc/${var.environment}-eks-flow-logs"
  retention_in_days = 14

  tags = {
    Name = "${var.environment}-eks-vpc-flow-logs"
  }
}

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
