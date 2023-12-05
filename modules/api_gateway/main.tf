resource "aws_api_gateway_rest_api" "this" {
  name        = "coffeerun-${var.infra_env}-api"
  description = "Main API for CoffeeRun App"
}

resource "aws_api_gateway_api_key" "this" {
  name = "coffeerun-general"
  description = "API Key for general access to coffee run api"
}

resource "aws_api_gateway_usage_plan" "this" {
  name = "coffeerun-general"
  description = "Usage plan for coffee run api"

  api_stages {
    api_id = aws_api_gateway_rest_api.this.id
    stage = aws_api_gateway_stage.this.stage_name

  }
}

resource "aws_api_gateway_usage_plan_key" "this" {
  key_id = aws_api_gateway_api_key.this.id
  key_type = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.this.id
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

resource "aws_api_gateway_method" "get_daily_coffee" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.daily_coffee.id
  http_method   = "GET"
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "get_daily_coffee" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_method.get_daily_coffee.resource_id
  http_method = aws_api_gateway_method.get_daily_coffee.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.daily_coffee_arn
}

resource "aws_api_gateway_method" "opt_daily_coffee" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.daily_coffee.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "opt_daily_coffee" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_method.opt_daily_coffee.resource_id
  http_method = aws_api_gateway_method.opt_daily_coffee.http_method
  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "opt_daily_coffee" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.daily_coffee.id
  http_method = aws_api_gateway_method.opt_daily_coffee.http_method
  status_code = aws_api_gateway_method_response.opt_daily_coffee.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_method_response" "opt_daily_coffee" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.daily_coffee.id
  http_method = aws_api_gateway_method.opt_daily_coffee.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.daily_coffee_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"
  depends_on = [
    aws_api_gateway_integration.get_daily_coffee
  ]
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    aws_api_gateway_method.get_daily_coffee,
    aws_api_gateway_integration.get_daily_coffee
  ]

  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.this.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "${var.infra_env}"
}
