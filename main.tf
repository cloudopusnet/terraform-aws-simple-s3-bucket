data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  bucket_name = coalesce(
    var.bucket_name,
    "${random_id.suffix.hex}-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}"
  )
  versioning_enabled        = var.versioning_enabled == false ? "Disabled" : "Enabled"
  override_policy_documents = var.custom_bucket_policy_document != null ? [var.custom_bucket_policy_document] : []
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "main" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = local.versioning_enabled
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_iam_policy_document" "main" {
  statement {
    sid       = "ForceSSLOnlyAccess"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.main.arn, "${aws_s3_bucket.main.arn}/*"]

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
  }


  dynamic "statement" {
    for_each = var.vpc_flow_log_policies ? [1] : []

    content {
      sid    = "AWSLogDeliveryWrite"
      effect = "Allow"
      actions = [
        "s3:PutObject"
      ]
      resources = [
        "arn:aws:s3:::${local.bucket_name}/*"
      ]
      principals {
        type        = "Service"
        identifiers = ["delivery.logs.amazonaws.com"]
      }
      condition {
        test     = "StringEquals"
        variable = "s3:x-amz-acl"

        values = [
          "bucket-owner-full-control"
        ]
      }
    }
  }

  dynamic "statement" {
    for_each = var.vpc_flow_log_policies ? [1] : []

    content {
      sid = "AWSLogDeliveryAclCheck"
      actions = [
        "s3:GetBucketAcl"
      ]
      resources = [
        "arn:aws:s3:::${local.bucket_name}"
      ]
      principals {
        type        = "Service"
        identifiers = ["delivery.logs.amazonaws.com"]
      }
    }
  }

  override_policy_documents = local.override_policy_documents
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.bucket
  policy = data.aws_iam_policy_document.main.json
}
