locals {
  info_out_directory = "${path.root}/out_info"
  info_out_archive   = "archive_${var.product.domain}_${var.product.name}-info.zip"

  out_directory      = "${path.root}/out_archives"
}

resource "local_file" "lambda_info_to_s3" {
  content = templatefile("${path.module}/templates/info.js.tftpl", {
    response_message = jsonencode({
      domain = var.product.domain
      name   = var.product.name
      output = {
        glue_database    = var.glue_database_arn
        location         = var.s3_bucket.arn
      }
    })
  })
  filename = "${local.info_out_directory}/lambda_function.js"
}

data "archive_file" "archive_info_to_s3" {
  type = "zip"

  source_dir  = local.info_out_directory
  output_path = "${local.out_directory}/${local.info_out_archive}"

  depends_on = [ local_file.lambda_info_to_s3 ]
}

resource "aws_s3_object" "archive_info_to_s3_object" {
  bucket = var.s3_bucket.bucket

  key    = "lambdas/${local.info_out_archive}"
  source = data.archive_file.archive_info_to_s3.output_path
  etag   = data.archive_file.archive_info_to_s3.output_md5

  depends_on = [ data.archive_file.archive_info_to_s3 ]
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "s3-lambda-execution-role-${var.product.domain}-${var.product.name}"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_lambda_function" "lambda_info" {
  function_name     = "${var.product.domain}_${var.product.name}_info"

  s3_bucket         = var.s3_bucket.bucket
  s3_key            = aws_s3_object.archive_info_to_s3_object.key
  s3_object_version = aws_s3_object.archive_info_to_s3_object.version_id

  runtime           = "nodejs12.x"
  handler           = "lambda_function.handler"
  source_code_hash  = data.archive_file.archive_info_to_s3.output_base64sha256

  role = aws_iam_role.lambda_execution_role.arn
}

resource "aws_apigatewayv2_api" "lambda_info" {
  name          = "${var.product.domain}_${var.product.name}_info"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda_info_prod" {
  api_id = aws_apigatewayv2_api.lambda_info.id

  name        = "prod"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.lambda_info.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    }
    )
  }
}

resource "aws_apigatewayv2_integration" "lambda_info" {
  api_id = aws_apigatewayv2_api.lambda_info.id

  integration_uri    = aws_lambda_function.lambda_info.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "lambda_info" {
  api_id = aws_apigatewayv2_api.lambda_info.id

  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_info.id}"
}

resource "aws_cloudwatch_log_group" "lambda_info" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda_info.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "lambda_info" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_info.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda_info.execution_arn}/*/*"
}
