# EFS setup for EKS pods

resource "aws_efs_file_system" "eks_efs" {
  creation_token   = "eks-efs-${var.environment}"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true

  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }

  tags = {
    Name = "eks-efs-${var.environment}"
  }
}

resource "aws_security_group" "efs" {
  name        = "eks-efs-sg-${var.environment}"
  description = "Security group to allow EKS nodes to mount EFS - Managed by Terraform."
  vpc_id      = aws_vpc.eks.id

  ingress {
    description = "Allow NFS access from EKS private subnets - Managed by Terraform."
    protocol    = "tcp"
    to_port     = 2049
    from_port   = 2049
    cidr_blocks = [
      for subnet in aws_subnet.eks_private : subnet.cidr_block
    ]
  }

  tags = {
    Name = "eks-efs-sg-${var.environment}"
  }
}

resource "aws_efs_mount_target" "eks_efs" {
  count           = length(var.private_subnet_cidrs)
  file_system_id  = aws_efs_file_system.eks_efs.id
  subnet_id       = aws_subnet.eks_private[count.index].id
  security_groups = [aws_security_group.efs.id]
}

# EFS Outputs for reference

output "efs_file_system_id" {
  value = aws_efs_file_system.eks_efs.id
}
