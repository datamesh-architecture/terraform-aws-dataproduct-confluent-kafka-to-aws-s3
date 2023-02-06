module "kafka_s3" {
  source = "./modules/kafka_s3"
  aws                   = var.aws
  kafka_api_credentials = var.kafka_api_credentials
  kafka                 = var.kafka
  s3_bucket             = var.s3_bucket

  kafka_topics = [ "stock" ]
}
