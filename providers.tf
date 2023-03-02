terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.56"
    }
    confluent = {
      source  = "confluentinc/confluent"
      version = ">= 1.34"
    }
  }
}

provider "aws" {
  region     = var.aws.region
  access_key = var.aws.access_key
  secret_key = var.aws.secret_key
}

provider "confluent" {
  cloud_api_key    = var.confluent.cloud_api_key
  cloud_api_secret = var.confluent.cloud_api_secret
}
