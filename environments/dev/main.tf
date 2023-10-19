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

  infra_env = "dev"
}

module "api_app" {
  source = "../../modules/api_gateway"

  infra_env         = var.infra_env
  daily_coffee_name = module.lambda_functions.daily_coffee_name
  daily_coffee_arn  = module.lambda_functions.daily_coffee_arn

  depends_on = [module.lambda_functions]
}
