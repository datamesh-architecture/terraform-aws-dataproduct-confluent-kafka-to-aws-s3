variable "s3_bucket" {
  type = object({
    bucket = string
    id     = string
    arn    = string
  })
}

variable "glue_database_name" {
  type = string
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
