variable "aws_glue" {
  type = object({
    database_name = string
    catalog_id    = string
  })
}

variable "s3_bucket" {
  type = object({
    bucket = string
    id     = string
    arn    = string
  })
}

variable "product" {
  type = object({
    fqn   = string
    input = list(object({
      topic      = string
      format     = string
      table_name = string
      schema     = string
    }))
  })
}
