variable "environment" {
  description = "Environment being deployed."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, production."
  }
}

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

# Variables for EKS Cluster

variable "control_plane_log_types" {
  description = "List of control plane log types to enable for the EKS cluster. Can include: api, audit, authenticator, controllerManager, scheduler."
  type        = list(string)
  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
}

variable "eks_service_cidr" {
  description = "CIDR block for the EKS service network."
  type        = string
  default     = "192.168.0.0/16"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = null
}

variable "admin_access_username" {
  description = "Name of the IAM role for user access to the EKS cluster."
  type        = string
  default     = "ckatraining"
}
# Variables for EKS Node Group

variable "node_group_desired_size" {
  description = "Desired number of nodes in the EKS node group."
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the EKS node group."
  type        = number
  default     = 1
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the EKS node group."
  type        = number
  default     = 1
}

variable "eks_capacity_type" {
  description = "Capacity type for the EKS node group (e.g., ON_DEMAND, SPOT)."
  type        = string
  default     = "ON_DEMAND"
}

variable "node_group_instance_types" {
  description = "List of instance types for the EKS node group."
  type        = list(string)
  default     = ["t4g.medium"]
}

variable "eks_labels" {
  description = "Labels to apply to the EKS node group."
  type        = map(string)
  default     = {}
}

variable "node_group_taints" {
  description = "List of taints to apply to the EKS node group."
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "node_group_ami_type" {
  description = "AMI type for the EKS node group."
  type        = string
  default     = "AL2023_ARM_64_STANDARD"
}
