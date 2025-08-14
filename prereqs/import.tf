# import.tf - Terraform import blocks for prereqs
# Uses data sources for account_id and region from versions.tf

import {
  to = aws_s3_bucket.tf_state
  id = "s3-tf-eks-helm-automation-state-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"
}

import {
  to = aws_s3_bucket_versioning.tf_state_versioning
  id = "s3-tf-eks-helm-automation-state-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"
}

import {
  to = aws_s3_bucket_server_side_encryption_configuration.tf_state_encryption
  id = "s3-tf-eks-helm-automation-state-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"
}

import {
  to = aws_s3_bucket_public_access_block.tf_state_block
  id = "s3-tf-eks-helm-automation-state-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"
}

import {
  to = aws_s3_bucket_lifecycle_configuration.tf_state_lifecycle
  id = "s3-tf-eks-helm-automation-state-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"
}

import {
  to = aws_s3_bucket_policy.tf_state_policy
  id = "s3-tf-eks-helm-automation-state-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"
}

import {
  to = aws_iam_openid_connect_provider.github_actions
  id = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
}

import {
  to = aws_iam_role.github_actions
  id = "github-actions-oidc-role"
}

# import {
#   to = aws_iam_policy.github_actions_state
#   id = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/github-actions-state-policy"
# }

# import {
#   to = aws_iam_role_policy_attachment.github_actions_attach
#   id = "github-actions-oidc-role/arn:aws:iam::aws:policy/ReadOnlyAccess"
# }

# import {
#   to = aws_iam_role_policy_attachment.github_actions_state_attach
#   id = "github-actions-oidc-role/github-actions-state-policy"
# }
