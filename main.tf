locals {
  product_fqn = replace("${var.domain}-${var.name}", "_", "-")
}

module "s3_bucket" {
  source = "./modules/aws_s3"
  s3_bucket_name = local.product_fqn
}

module "confluent_kafka_to_s3" {
  source = "./modules/confluent_kafka_s3"

  /* credentials required for the module */
  aws                   = var.aws
  kafka_api_credentials = var.kafka_api_credentials
  kafka                 = var.kafka

  s3_bucket             = module.s3_bucket.s3_bucket.bucket
  kafka_topics          = [ for input in var.input: input.topic ]

  depends_on = [ module.s3_bucket ]
}

module "athena_glue" {
  source = "./modules/aws_athena_glue"

  glue_catalog_database = var.glue_catalog_database

  product = {
    fqn   = local.product_fqn
    input = var.input
  }
}
