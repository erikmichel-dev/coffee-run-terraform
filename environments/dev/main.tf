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