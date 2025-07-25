# tf-eks-helm-automation - CoPilot Instructions

This repository contains Terraform configurations and Helm charts for automating the deployment of applications on Amazon EKS (Elastic Kubernetes Service).

## Project Context
- GitHub Actions for CI/CD workflows.
- Terraform for infrastructure as code.
- Helm for managing Kubernetes applications.

## Coding Standards
- Use Terraform best practices for resource naming and organisation.
- Follow consistent file naming conventions.
- Follow AWS resource naming conventions, with consistent prefixes for resources.
- Use "Name" tags for all AWS resources.
- Use data sources to reference existing resources where applicable.
- Include comprehensive variable descriptions with type constraints.
- Add output values for important resource attributes.
- Give clear descriptions for any resources and modules.
- Suffix AWS resource descriptions with " - Managed by Terraform".

## Variables
- Use `variables.tf` to define all input variables.
- Use `terraform.tfvars.example` to provide example values for variables.
- Use `sensitive = true` for sensitive variables.
- Use terraform fmt and terraform validate before committing changes.
- Document resources with inline comments to describe purpose.

## AWS Services
- IAM for permission management.
- EKS for Kubernetes clusters.
- S3 for state storage.

## Security Considerations
- Use IAM roles with least privilege.
- Store sensitive data in AWS Secrets Manager or SSM Parameter Store.
- Secure S3 buckets with appropriate policies, and ensure they are private.
- Do not use wildcard permissions in IAM policies.
- Implement security groups with least privilege access and specific ports and protocols.
- Use encryption for sensitive data at rest and in transit.
- Use S3 based locking for Terraform state files.

## Development Guidelines
When suggesting code changes or new features, consider:
1. **Quality**: Ensure readability, maintainability, and proper documentation.
2. **Security First**: All security considerations must be implemented by default.
3. **Environment Separation**: Support for multiple environments (e.g. dev, staging, prod) should be considered.
4. **Error Handling**: Implement proper error handling and logging.
5. **Logging and Monitoring**: Ensure that logging and monitoring are set up for all critical components.
6. **Backward Compatibility**: Ensure that changes do not break existing functionality unless explicitly stated.
7. **Testing**: Include unit tests and integration tests where applicable.
8. **Performance**: Consider performance implications of changes, especially in resource-intensive operations.
9. **Documentation**: Update README files and inline comments to reflect changes made.