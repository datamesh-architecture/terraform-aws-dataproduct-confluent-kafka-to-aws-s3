output "s3_bucket" {
  value = module.aws_s3.s3_bucket
}

output "data_product_endpoint" {
  value = module.aws_lambda.data_product_endpoint
}
