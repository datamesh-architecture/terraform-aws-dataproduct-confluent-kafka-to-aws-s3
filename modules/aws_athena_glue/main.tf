resource "aws_glue_schema" "aws_glue_schema" {
  count = length(var.product.input)

  compatibility     = "DISABLED"
  data_format       = var.product.input[count.index].format
  schema_name       = "schema_${var.product.fqn}_${var.product.input[count.index].table_name}"
  schema_definition = file("${path.cwd}/${var.product.input[count.index].schema}")
}

resource "aws_glue_catalog_table" "aws_glue_catalog_table_kafka" {
  count = length(var.product.input)

  database_name = var.aws_glue.database_name
  catalog_id    = var.aws_glue.catalog_id
  name          = replace(var.product.input[count.index].table_name, "-", "_")
  description   = "Glue catalog table"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL = "true"
    "classification" = lower(var.product.input[count.index].format)
  }

  storage_descriptor {
    location      = "s3://${var.s3_bucket.id}/topics/${var.product.input[count.index].topic}"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = lower(var.product.input[count.index].format) == "json" ? "org.openx.data.jsonserde.JsonSerDe" : file("ERROR: Currently only JSON supported")
    }

    schema_reference {
      schema_version_number = aws_glue_schema.aws_glue_schema[count.index].latest_schema_version
      schema_id {
        schema_arn = aws_glue_schema.aws_glue_schema[count.index].arn
      }
    }
  }
}
