output "aws_glue_catalog_tables" {
  value = aws_glue_catalog_table.aws_glue_catalog_table_kafka[*].arn
}
