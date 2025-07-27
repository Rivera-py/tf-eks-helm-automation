output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket used for Terraform state."
  value       = aws_s3_bucket.tf_state.arn
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC provider created for GitHub Actions."
  value       = aws_iam_openid_connect_provider.github_actions.arn

}

output "iam_role_arn" {
  description = "The ARN of the IAM role created for GitHub Actions."
  value       = aws_iam_role.github_actions.arn
}
