variable "glue_catalog_database" {
  type = object({
    name       = string
    catalog_id = string
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
