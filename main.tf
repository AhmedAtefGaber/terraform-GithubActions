provider "aws" {
  region = var.aws_region
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-function"
  output_path = "${path.module}/lambda-function.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name    = "lambda-function"
  filename         = "${path.module}/lambda-function.zip"
  runtime          = "python3.6"
  handler          = "app.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = aws_iam_role.lambda-iam.arn
}

resource "aws_cloudwatch_log_group" "lambda" {
  name = "/aws/lambda/${aws_lambda_function.lambda.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda-iam" {
  name = "lambda-iam"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda-iam.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_apigatewayv2_api" "lambda-api" {
  name          = "v2-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda-stage" {
  api_id      = aws_apigatewayv2_api.lambda-api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda-integration" {
  api_id                = aws_apigatewayv2_api.lambda-api.id
  integration_uri       = aws_lambda_function.lambda.invoke_arn
  integration_type      = "AWS_PROXY"
  integration_method    = "POST"
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.lambda-api.id
  route_key = "ANY /api"
  target    = "integrations/${aws_apigatewayv2_integration.lambda-integration.id}"
}

resource "aws_lambda_permission" "api-gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda-api.execution_arn}/*/*"
}
