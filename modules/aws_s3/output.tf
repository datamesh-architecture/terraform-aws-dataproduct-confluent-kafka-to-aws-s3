output "s3_bucket" {
  value = {
    bucket = aws_s3_bucket.aws_s3_bucket.bucket
    id     = aws_s3_bucket.aws_s3_bucket.id
    arn    = aws_s3_bucket.aws_s3_bucket.arn
  }
}
