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

variable "glue_database_arn" {
  type = string
}
