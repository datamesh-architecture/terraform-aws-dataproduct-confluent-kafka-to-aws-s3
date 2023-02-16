locals {
  product_fqn = replace("${var.domain}-${var.name}", "_", "-")
}

module "aws_s3" {
  source = "./modules/aws_s3"
  s3_bucket_name = local.product_fqn
  aws_account_ids = var.output.grant_access
}

module "confluent_kafka_to_s3" {
  source = "./modules/confluent_kafka_s3"

  aws                   = var.aws
  kafka_api_credentials = var.kafka_api_credentials
  kafka                 = var.kafka
  s3_bucket             = module.aws_s3.s3_bucket.bucket
  kafka_topics          = [ for input in var.input: input.topic ]

  depends_on = [ module.aws_s3 ]
}

module "aws_athena_glue" {
  source = "./modules/aws_athena_glue"

  aws_glue  = var.aws_glue
  s3_bucket = module.aws_s3.s3_bucket

  product  = {
    fqn    = local.product_fqn
    input  = var.input
  }
}

module "aws_lambda" {
  source = "./modules/aws_lambda"

  s3_bucket  = module.aws_s3.s3_bucket
  aws_athena = var.aws_athena
  aws_glue   = {
    database_name  = var.aws_glue.database_name
    catalog_tables = module.aws_athena_glue.aws_glue_catalog_tables
  }

  product = {
    domain = var.domain
    name   = var.name
  }
}
