locals {
  s3_bucket_name = "datamesh-dataproduct-input-stock"
}

module "s3_bucket" {
  source = "./modules/aws_s3"
  s3_bucket_name = local.s3_bucket_name
}

module "kafka_s3" {
  source = "./modules/kafka_s3"
  aws                   = var.aws
  kafka_api_credentials = var.kafka_api_credentials
  kafka                 = var.kafka

  s3_bucket    = local.s3_bucket_name
  kafka_topics = [ "stock" ]

  depends_on = [ module.s3_bucket ]
}
