data "archive_file" "daily_coffee" {
  type        = "zip"
  source_dir  = "${path.module}/daily_coffee/"
  output_path = "${path.module}/daily_coffee/daily_coffee.zip"
}

data "archive_file" "populate_coffee_pool" {
  type        = "zip"
  source_dir  = "${path.module}/populate_coffee_pool/"
  output_path = "${path.module}/populate_coffee_pool/populate_coffee_pool.zip"
}

resource "aws_lambda_function" "daily_coffee" {
  filename         = data.archive_file.daily_coffee.output_path
  source_code_hash = data.archive_file.daily_coffee.output_base64sha256
  role             = aws_iam_role.daily_coffee.arn
  function_name    = "daily_coffee-${var.infra_env}"
  handler          = "daily_coffee.lambda_handler"
  runtime          = "python3.11"

  environment {
    variables = {
      COFFEE_POOL_TABLE_NAME = var.coffee_pool_table_name
      TIER_LIST_TABLE_NAME   = var.tier_list_table_name
      REGION                 = var.region
    }
  }
}

resource "aws_lambda_function" "populate_coffee_pool" {
  filename         = data.archive_file.populate_coffee_pool.output_path
  source_code_hash = data.archive_file.populate_coffee_pool.output_base64sha256
  role             = aws_iam_role.populate_coffee_pool.arn
  function_name    = "populate_coffee_pool-${var.infra_env}"
  handler          = "populate_coffee_pool.lambda_handler"
  runtime          = "python3.11"

  environment {
    variables = {
      COFFEE_POOL_TABLE_NAME = var.coffee_pool_table_name
      REGION                 = var.region
    }
  }
}

