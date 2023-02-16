output "data_product_endpoint" {
  value = aws_apigatewayv2_stage.lambda_info_prod.invoke_url
}
