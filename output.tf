output "discovery_endpoint" {
  value       = "${aws_apigatewayv2_api.lambda_info.api_endpoint}/${aws_apigatewayv2_stage.lambda_info_prod.name}"
  description = "The URI of the generated discovery endpoint"
}
