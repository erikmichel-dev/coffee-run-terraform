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