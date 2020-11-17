resource "aws_s3_bucket" "bucket" {
  bucket = element(var.buckets, count.index)
  acl    = "private"

  versioning {
    enabled = var.versioning
  }

  lifecycle_rule {
    id      = "expiration_days"
    enabled = var.expiration_days != 0 ? true : false

    expiration {
      days = var.expiration_days
    }
  }

  count = length(var.buckets)
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = element(var.buckets, count.index)

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false

  count = length(var.buckets)
}

data "aws_iam_policy_document" "sse" {
  statement {
    sid    = "DenyIncorrectEncryptionHeader"
    effect = "Deny"

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    actions = ["s3:PutObject"]
    resources = [
      format("%s/*", element(aws_s3_bucket.bucket.*.arn, count.index)),
    ]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["AES256"]
    }
  }

  statement {
    sid    = "DenyUnEncryptedObjectUploads"
    effect = "Deny"

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    actions = ["s3:PutObject"]

    resources = [
      format("%s/*", element(aws_s3_bucket.bucket.*.arn, count.index)),
    ]

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }
  }

  count = var.sse ? length(var.buckets) : 0
}

resource "aws_s3_bucket_policy" "sse" {
  bucket = element(aws_s3_bucket.bucket.*.id, count.index)
  policy = element(data.aws_iam_policy_document.sse.*.json, count.index)

  count = var.sse ? length(var.buckets) : 0
}

output "arn" {
  value = aws_s3_bucket.bucket.*.arn
}

output "id" {
  value = aws_s3_bucket.bucket.*.id
}
