# resource "aws_eks_cluster" "cluster" {
#   name     = "eks-cluster-${var.environment}"
#   role_arn = aws_iam_role.eks_service_role.arn
# }
