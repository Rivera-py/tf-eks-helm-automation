# Variables for EKS Network Resources
variable "vpc_cidr" {
  description = "CIDR block for the EKS VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets."
  type        = list(string)
  default = [
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24"
  ]
}

variable "azs" {
  description = "List of availability zones to use for subnets."
  type        = list(string)
  default = [
    "eu-west-2a",
    "eu-west-2b",
    "eu-west-2c"
  ]
}

variable "allowed_public_ingress_ip" {
  description = "The public IP allowed to access the public subnet on port 443."
  type        = string
  default     = "198.51.100.10/32" # Example IP, replace as needed
}

# EKS Network Resources

resource "aws_vpc" "eks" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment}-eks-vpc"
  }
}

resource "aws_default_security_group" "eks_default_block_all" {
  vpc_id                 = aws_vpc.eks.id
  revoke_rules_on_delete = true

  ingress = []
  egress  = []

  tags = {
    Name = "${var.environment}-eks-default-block-all"
  }
}

resource "aws_subnet" "eks_public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.eks.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone       = element(var.azs, count.index)

  tags = {
    Name = "${var.environment}-eks-public-${element(var.azs, count.index)}"
    Type = "public"
  }
}

resource "aws_subnet" "eks_private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.eks.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.environment}-eks-private-${element(var.azs, count.index)}"
    Type = "private"
  }
}

resource "aws_internet_gateway" "eks" {
  vpc_id = aws_vpc.eks.id

  tags = {
    Name = "${var.environment}-eks-igw"
  }
}

resource "aws_nat_gateway" "eks" {
  allocation_id = aws_eip.eks_nat.id
  subnet_id     = aws_subnet.eks_public[0].id

  tags = {
    Name = "${var.environment}-eks-nat"
  }
}

resource "aws_eip" "eks_nat" {
  tags = {
    Name = "${var.environment}-eks-nat-eip"
  }
}

resource "aws_route_table" "eks_public" {
  vpc_id = aws_vpc.eks.id
  tags = {
    Name = "${var.environment}-eks-public-rt"
    Type = "public"
  }
}

resource "aws_route" "eks_public_internet_access" {
  route_table_id         = aws_route_table.eks_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks.id
}

resource "aws_route_table_association" "eks_public" {
  count          = length(aws_subnet.eks_public)
  subnet_id      = aws_subnet.eks_public[count.index].id
  route_table_id = aws_route_table.eks_public.id
}

resource "aws_route_table" "eks_private" {
  vpc_id = aws_vpc.eks.id
  tags = {
    Name = "${var.environment}-eks-private-rt"
    Type = "private"
  }
}

resource "aws_route" "eks_private_nat_access" {
  route_table_id         = aws_route_table.eks_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.eks.id
}

resource "aws_route_table_association" "eks_private" {
  count          = length(aws_subnet.eks_private)
  subnet_id      = aws_subnet.eks_private[count.index].id
  route_table_id = aws_route_table.eks_private.id
}

output "eks_vpc_id" {
  description = "VPC ID for EKS cluster"
  value       = aws_vpc.eks.id
}

output "eks_public_subnet_ids" {
  description = "Public subnet IDs for EKS cluster"
  value       = aws_subnet.eks_public[*].id
}

output "eks_private_subnet_ids" {
  description = "Private subnet IDs for EKS cluster"
  value       = aws_subnet.eks_private[*].id
}
