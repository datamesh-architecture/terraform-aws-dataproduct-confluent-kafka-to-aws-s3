variable "product" {
  type = object({
    domain    = string
    name      = string
  })
}

variable "s3_bucket" {
  type = object({
    bucket = string
    id     = string
    arn    = string
  })
}

variable "aws_athena" {
  type = object({
    workgroup_name = string
    catalog_name   = string
  })
}

variable "aws_glue" {
  type = object({
    database_name  = string
    catalog_tables = list(string)
  })
}
