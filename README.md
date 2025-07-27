# tf-eks-helm-automation

This repository contains Terraform configurations and Helm charts for automating the deployment of applications on Amazon EKS (Elastic Kubernetes Service).

## Features

- Infrastructure as Code for EKS clusters using Terraform
- Helm charts for Kubernetes application management
- Automated CI/CD workflows with GitHub Actions
- Secure S3 state storage with locking
- Environment separation (dev, staging, prod)
- Security best practices for AWS resources

## Getting Started

1. **Clone the repository:**
   ```sh
   git clone https://github.com/your-org/tf-eks-helm-automation.git
   ```

2. **Create Required Resources:**
   - Update `prereqs/terraform.tfvars` with GitHub Org and repo.
   - Deploy prereqs Terraform to set up state bucket, IAM role and OIDC.

5. **Trigger workflow:**
   Trigger main deployment workflow to deploy stacks.

## CI/CD Workflow

- **Feature Branch Push:** Runs `terraform plan` and formatting/validation checks.
- **Pull Request:** Triggers security scans (tfsec, checkov) and adds results to PR.
- **Merge to Main/Env Branch:** Runs `terraform apply` with approval.
- **Reusable Workflows:** See `.github/workflows/terraform-setup.yaml` for modular workflow design.

## Security Considerations

- IAM roles with least privilege
- S3 buckets for state are private and encrypted
- No wildcard permissions in IAM policies
- Sensitive data stored in AWS Secrets Manager or SSM Parameter Store
- Security groups restrict access to specific ports/protocols

## Development Guidelines

- Use `variables.tf` for all input variables with descriptions and type constraints
- Use `terraform.tfvars.example` for example values
- Run `terraform fmt` and `terraform validate` before committing
- Document resources with inline comments
- Add output values for important resource attributes
- Update README and documentation for any changes

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.
