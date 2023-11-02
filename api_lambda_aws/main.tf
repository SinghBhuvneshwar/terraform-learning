provider "aws" {
  region     = "***"
  access_key = "***"
  secret_key = "***"

}

data "aws_region" "current" {}

# 1 AWS role for lambda function 

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

# 2. IAM policy attachment to Lambda execution role

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_execution_role.name
}

# 3. data to archive

data "archive_file" "zip" {
  type        = "zip"
  source_file = "${path.module}/python/welcome.py"
  output_path = "${path.module}/python/welcome.zip"
}

# 4. lambda function

resource "aws_lambda_function" "lambda" {
  filename      = "${path.module}/python/welcome.zip"
  function_name = "mylambda"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "welcome.lambda_handler"
  runtime       = "python3.8"
  depends_on    = [aws_iam_role_policy_attachment.lambda_execution_policy_attachment]
}

# lambda permission for api gateway

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowInvokeFromAPIGatewayGet"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/${aws_lambda_function.lambda.function_name}"
}

# rest api create

resource "aws_api_gateway_rest_api" "api" {
  name = "myapi"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# gateway resource

resource "aws_api_gateway_resource" "resource" {
  path_part   = "resource"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

# gateway method

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# gateway integration with lambda

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

# API Gateway deployment

resource "aws_api_gateway_deployment" "deployment" {
  stage_name  = "Dev"
  rest_api_id = aws_api_gateway_rest_api.api.id
  depends_on  = [aws_api_gateway_integration.lambda_integration]
}

# Output the API Gateway Invoke URL

output "invoke_url" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}

