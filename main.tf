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
  kafka                 = var.kafka

  s3_bucket             = module.aws_s3.s3_bucket.bucket
  kafka_topics          = [ for input in var.input: input.topic ]

  depends_on = [ module.aws_s3 ]
}

module "aws_athena_glue" {
  source = "./modules/aws_glue"

  s3_bucket          = module.aws_s3.s3_bucket
  glue_database_name = local.product_fqn

  product  = {
    fqn    = local.product_fqn
    input  = var.input
  }
}

module "aws_lambda" {
  source = "./modules/aws_lambda"

  s3_bucket         = module.aws_s3.s3_bucket
  glue_database_arn = module.aws_athena_glue.glue_database_arn

  product = {
    domain = var.domain
    name   = var.name
  }
}
