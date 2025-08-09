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

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.
