data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" "tf_state" {
  bucket        = "s3-tf-eks-helm-automation-state-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"
  force_destroy = true

  tags = {
    Name = "terraform-state-bucket"
  }
}

resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_encryption" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state_block" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "tf_state_policy" {
  bucket = aws_s3_bucket.tf_state.id
  policy = data.aws_iam_policy_document.tf_state_policy.json
}

data "aws_iam_policy_document" "tf_state_policy" {
  statement {
    sid    = "DenyUnEncryptedObjectUploads"
    effect = "Deny"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.tf_state.arn}/*"
    ]
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["AES256"]
    }
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tf_state_lifecycle" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    filter {} # Required by provider when no prefix or filter is specified

    noncurrent_version_expiration {
      noncurrent_days = 30 # Remove noncurrent (old) versions after 30 days
    }
  }
}
