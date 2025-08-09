# tf-eks-helm-automation

This repository provides automated, secure, and modular infrastructure for deploying applications on Amazon EKS (Elastic Kubernetes Service) using Terraform and Helm. It implements AWS best practices for security, environment separation, and automation.

## Overview

- **Infrastructure as Code:** Terraform modules for EKS, VPC, IAM, logging, and networking.
- **Kubernetes Management:** Helm charts for application deployment and lifecycle management.
- **CI/CD Automation:** GitHub Actions workflows for validation, security scanning, and deployment.
- **Security:** Least-privilege IAM, encrypted S3 state, VPC Flow Logs, and strict network controls.
- **Environment Separation:** Supports dev, staging, and prod via workspaces and variable files.

## AWS Architecture (High-Level)

- **VPC:** Custom VPC with public and private subnets across multiple AZs for high availability.
- **Subnets:** Public subnets for load balancers; private subnets for EKS nodes and internal workloads.
- **Internet Gateway (IGW):** Provides internet access for public subnets.
- **NAT Gateway:** Allows private subnets to access the internet securely.
- **Route Tables & NACLs:** Segregated routing and network ACLs for least-privilege access.
- **IAM:** Roles and policies for EKS, GitHub Actions, and logging, following least-privilege principles.
- **EKS Cluster:** Managed Kubernetes control plane and node groups.
- **S3:** Secure, encrypted bucket for Terraform state with state locking.
- **CloudWatch Logs:** Centralized logging for VPC Flow Logs and auditing.

## GitHub Actions Workflows

Workflows are defined in `.github/workflows/` and follow a modular, reusable pattern:

- **`aws-dev-terraform-test.yaml`:**
  - **Triggers:** On push and pull request to `feature/*` branches.
  - **Flow:**
    1. Calls reusable `terraform.yaml` workflow with parameters for stack, environment, region, IAM role, and state bucket.
    2. Runs Terraform plan, linting, validation, and security scans.
    3. Publishes test and scan results as workflow artifacts.

- **`terraform.yaml`:** (Reusable Workflow)
  - **Parameters:** Action, stack, environment, AWS region, IAM role, state bucket prefix.
  - **Steps:**
    1. Checkout code
    2. Setup Terraform
    3. Configure AWS credentials (OIDC/GitHub Actions role)
    4. Initialize Terraform with S3 backend
    5. Select/create workspace
    6. Run `terraform fmt` and `terraform validate`
    7. Run `terraform plan` (outputs JSON plan)
    8. Run TFLint and Checkov for linting and security
    9. Publish results and upload plan artifact

- **Security:**
  - No hardcoded secrets; uses OIDC and IAM roles.
  - S3 state is encrypted and locked.
  - All workflows run security and compliance checks (TFLint, Checkov).

## Security Best Practices

- IAM roles and policies grant only required permissions (no wildcards).
- S3 state bucket is private, encrypted, and uses state locking.
- Sensitive data is stored in AWS Secrets Manager or SSM Parameter Store.
- Security groups and NACLs restrict access to required ports and protocols.
- VPC Flow Logs and CloudWatch for monitoring and auditing.
- Encryption is enabled for data at rest and in transit.

## EKS Cluster Security & Access

- **Secrets Encryption:** EKS secrets are encrypted at rest using a customer-managed KMS key (CMK), managed by Terraform and restricted to EKS and your AWS account.
- **Control Plane Logging:** EKS control plane logs (API, audit, authenticator, controllerManager, scheduler) are sent to a dedicated, encrypted CloudWatch Log Group.
- **Admin Access:** Cluster admin access is managed using EKS Access Policy Associations (AmazonEKSAdminPolicy) or via the `aws-auth` ConfigMap. The new EKS Access Entry/Policy Association resources are used for fine-grained access control.
- **Kubernetes Network Config:** The cluster uses a custom service CIDR and supports encryption and upgrade policies.

## Project Setup Steps

## Getting Started

Follow these steps to provision and manage your EKS infrastructure:

### 0. Prerequisites

- **AWS CLI:** Installed and configured with a user that has sufficient IAM permissions (admin or equivalent).
- **kubectl:** Installed for interacting with your EKS cluster.
- **Terraform:** Installed (version >= 1.3 recommended).

### 1. Clone the Repository

```sh
git clone https://github.com/<your-org>/tf-eks-helm-automation.git
cd tf-eks-helm-automation
```

### 2. Configure Prerequisite Variables

Edit `prereqs/terraform.tfvars` and set the following values to match your GitHub organization and repository:

```hcl
github_org  = "your-github-org"
github_repo = "tf-eks-helm-automation"
```

### 3. Deploy Prerequisite Resources

Initialize and apply the Terraform configuration for prerequisites (e.g., S3 backend, IAM roles):

```sh
cd prereqs
terraform init
terraform apply
```

> **Note:** Prerequisite resources are typically permanent. You may manage their state locally or migrate to remote S3 as needed.

### 4. Configure Environment Variables

Edit the relevant environment variable files in `aws/environments/*.tfvars` to customize settings for each environment (dev, staging, prod):

```hcl
# Example: aws/environments/dev.tfvars
# TODO: add examples here as project develops
```

### 5. Deploy AWS Infrastructure

Initialize and apply the main Terraform configuration for your chosen environment:

```sh
cd ../aws
terraform init
terraform workspace new dev # or select an existing workspace
terraform apply -var-file="environments/dev.tfvars"
```

### 6. Update kubectl Access

After deployment, update your kubeconfig to access the EKS cluster:

```sh
aws eks update-kubeconfig --name <cluster_name>
```

You can now interact with your cluster using `kubectl`.

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.
