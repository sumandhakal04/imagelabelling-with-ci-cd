resource "aws_api_gateway_rest_api" "rest-api" {
  name = var.api-gw-name
}

resource "aws_api_gateway_resource" "proxy-var" {
  rest_api_id = aws_api_gateway_rest_api.rest-api.id
  parent_id   = aws_api_gateway_rest_api.rest-api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy-var-any" {
  rest_api_id   = aws_api_gateway_rest_api.rest-api.id
  resource_id   = aws_api_gateway_resource.proxy-var.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "proxy-var-response" {
  rest_api_id = aws_api_gateway_rest_api.rest-api.id
  resource_id = aws_api_gateway_resource.proxy-var.id
  http_method = aws_api_gateway_method.proxy-var-any.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "true",
    "method.response.header.Access-Control-Allow-Headers" = "true",
    "method.response.header.Access-Control-Allow-Methods" = "true"
  }
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.rest-api.id
  resource_id = aws_api_gateway_method.proxy-var-any.resource_id
  http_method = aws_api_gateway_method.proxy-var-any.http_method

  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.image-label-lambda.invoke_arn
}

resource "aws_api_gateway_integration_response" "lambda_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rest-api.id
  resource_id = aws_api_gateway_resource.proxy-var.id
  http_method = aws_api_gateway_method.proxy-var-any.http_method
  status_code = aws_api_gateway_method_response.proxy-var-response.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_integration.lambda, aws_api_gateway_method_response.proxy-var-response]
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda,
  ]

  rest_api_id = aws_api_gateway_rest_api.rest-api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.proxy-var.id,
      aws_api_gateway_method.proxy-var-any.id,
      aws_api_gateway_integration.lambda.id
    ]))
  }
}

resource "aws_api_gateway_stage" "rest_api_stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest-api.id
  stage_name    = var.api-gw-stage-name
}

resource "aws_lambda_permission" "apigw-lambda-permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image-label-lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rest-api.execution_arn}/*/*"
}