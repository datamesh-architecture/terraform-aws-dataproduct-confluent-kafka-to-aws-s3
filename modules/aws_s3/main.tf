# S3 bucket to store the results of the (Athena) query execution
resource "aws_s3_bucket" "aws_s3_bucket" {
  bucket = var.s3_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_acl" "aws_s3_bucket_acl" {
  bucket = aws_s3_bucket.aws_s3_bucket.id
  acl    = "private"
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
      values   = [ join(", ", [ for s in var.aws_account_ids : format("arn:aws:iam::%s:role/*", s) ]) ]
    }

    principals {
      type        = "AWS"
      identifiers = [ join(", ", [ for s in var.aws_account_ids : format("arn:aws:iam::%s:root", s) ]) ]
    }
  }
}
