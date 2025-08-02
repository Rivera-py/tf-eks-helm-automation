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
   - Update role referenced in terraform workflow inputs.

5. **Trigger workflow:**
   Trigger main deployment workflow to deploy stacks.

## GitHub Actions Workflows

The repository includes the following key workflow files in `.github/workflows/`:

- **`aws-dev-terraform-test.yaml`**
  - Triggers on push and pull request to `feature/*` branches.
  - Calls the reusable workflow `terraform.yaml` to perform Terraform plan and test steps for the `AWS` stack's `dev` environment.

- **`terraform.yaml`** (Reusable Workflow)
  - Accepts parameters for action, stack, environment, AWS region, IAM role, and state bucket prefix.
  - **Steps executed:**
    1. Checkout repository
    2. Setup Terraform
    3. Configure AWS credentials
    4. Initialize Terraform with remote S3 backend
    5. Select or create Terraform workspace
    6. Run `terraform fmt` for formatting
    7. Run `terraform validate` for validation
    8. Run `terraform plan` and output plan in JSON
    9. Setup and run TFLint with custom config
    10. Run Checkov for security scanning
    11. Publish test results (TFLint and Checkov)
    12. Upload Terraform plan as an artifact

- **Other workflow files** may be present for additional environments or stacks, following a similar pattern.

## CI/CD Workflow

- **Feature Branch Push:** Runs `terraform plan` and formatting/validation checks.
- **Pull Request:** Triggers security scans (tfsec, checkov) and adds results to PR.
- **Reusable Workflows:** See `.github/workflows/terraform.yaml` for modular workflow design.

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
