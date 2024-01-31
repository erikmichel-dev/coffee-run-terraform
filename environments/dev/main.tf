terraform {
  backend "s3" {
    region                 = "eu-south-2"
    encrypt                = true
    skip_region_validation = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-south-2"
}

module "lambda_functions" {
  source = "../../modules/lambda_functions"

  infra_env              = var.infra_env
  region                 = var.region
  coffee_pool_table_name = module.dynamodb_tables.coffee_pool_table_name
  tier_list_table_name   = module.dynamodb_tables.tier_list_table_name
}

module "api_app" {
  source = "../../modules/api_gateway"

  infra_env         = var.infra_env
  daily_coffee_name = module.lambda_functions.daily_coffee_name
  daily_coffee_arn  = module.lambda_functions.daily_coffee_arn

  depends_on = [module.lambda_functions]
}

module "dynamodb_tables" {
  source = "../../modules/dynamo_db"

  infra_env = var.infra_env
}

module "s3_hosting" {
  source = "../../modules/s3_hosting"

  region = var.region
  s3_name = "coffee-run-web-${var.infra_env}"
}