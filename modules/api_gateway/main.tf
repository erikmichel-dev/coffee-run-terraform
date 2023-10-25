resource "aws_api_gateway_rest_api" "this" {
  name        = "coffeerun-${var.infra_env}-api"
  description = "Main API for CoffeeRun App"
}

resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "api"
}


resource "aws_api_gateway_resource" "daily_coffee" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.root.id
  path_part   = "daily-coffee"
}

resource "aws_api_gateway_method" "daily_coffee" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.daily_coffee.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "daily_coffee" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_method.daily_coffee.resource_id
  http_method = aws_api_gateway_method.daily_coffee.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.daily_coffee_arn
}


resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.daily_coffee_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"
  depends_on = [
    aws_api_gateway_integration.daily_coffee
  ]
}

resource "aws_api_gateway_deployment" "dev" {
  depends_on = [
    aws_api_gateway_method.daily_coffee,
    aws_api_gateway_integration.daily_coffee
  ]

  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.this.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.dev.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "dev"
}
