output "discovery_endpoint" {
  value       = aws_apigatewayv2_stage.lambda_info_prod.invoke_url
  description = "The URI of the generated discovery endpoint"
}
