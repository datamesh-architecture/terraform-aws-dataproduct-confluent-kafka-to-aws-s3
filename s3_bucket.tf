# S3 bucket to store the results of the (Athena) query execution
resource "aws_s3_bucket" "aws_s3_bucket" {
  bucket = local.product_fqn
  force_destroy = true
}

resource "aws_kms_key" "aws_kms_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aws_s3_bucket_server_side_encryption_configuration" {
  bucket = aws_s3_bucket.aws_s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.aws_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.aws_s3_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

## allow_access_for_role -> lambda

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.aws_s3_bucket.arn,
      "${aws_s3_bucket.aws_s3_bucket.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = [ join(", ", [ for s in var.output.grant_access : format("arn:aws:iam::%s:role/*", s) ]) ]
    }

    principals {
      type        = "AWS"
      identifiers = [ join(", ", [ for s in var.output.grant_access : format("arn:aws:iam::%s:root", s) ]) ]
    }
  }
}
