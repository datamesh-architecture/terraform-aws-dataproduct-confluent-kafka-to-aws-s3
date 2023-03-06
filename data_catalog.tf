resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  name = local.product_fqn
}

resource "aws_glue_schema" "aws_glue_schema" {
  count = length(var.input)

  compatibility     = "NONE"
  data_format       = var.input[count.index].format
  schema_name       = "schema_${local.product_fqn}_${var.input[count.index].table_name}"
  schema_definition = file("${path.cwd}/${var.input[count.index].schema}")
}

resource "aws_glue_catalog_table" "aws_glue_catalog_table_kafka" {
  count = length(var.input)

  database_name = aws_glue_catalog_database.aws_glue_catalog_database.name
  catalog_id    = aws_glue_catalog_database.aws_glue_catalog_database.catalog_id
  name          = replace(var.input[count.index].table_name, "-", "_")
  description   = "Glue catalog table"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL = "true"
    "classification" = lower(var.input[count.index].format)
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.aws_s3_bucket.id}/topics/${var.input[count.index].topic}"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = lower(var.input[count.index].format) == "json" ? "org.openx.data.jsonserde.JsonSerDe" : file("ERROR: Currently only JSON supported")
    }

    schema_reference {
      schema_version_number = aws_glue_schema.aws_glue_schema[count.index].latest_schema_version
      schema_id {
        schema_arn = aws_glue_schema.aws_glue_schema[count.index].arn
      }
    }
  }
}
