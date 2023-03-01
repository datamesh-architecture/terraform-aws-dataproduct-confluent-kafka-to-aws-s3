variable "kafka_topics" {
  type = list(string)
}

variable "aws" {
  type = object({
    region     = string
    access_key = string
    secret_key = string
  })
  sensitive = true
}

variable "kafka" {
  type = object({
    environment = object({
      id = string
    })
    cluster = object({
      id = string
      api_version = string
      kind = string
      rest_endpoint = string
    })
    credentials = object({
      api_key_id = string
      api_key_secret = string
    })
  })
  sensitive = true
}

variable "s3_bucket" {
  type = string
  description = "Name of the S3 bucket where topic data should be stored"
}
