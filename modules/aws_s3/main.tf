# S3 bucket to store the results of the (Athena) query execution
resource "aws_s3_bucket" "aws_s3_bucket" {
  bucket = var.s3_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_acl" "aws_s3_bucket_acl" {
  bucket = aws_s3_bucket.aws_s3_bucket.id
  acl    = "private"
}
