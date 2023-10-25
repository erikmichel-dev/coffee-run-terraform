resource "aws_dynamodb_table" "coffee_pool" {
  name         = "coffee_pool-${var.infra_env}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "coffee_id"
  range_key    = "tier"

  attribute {
    name = "coffee_id"
    type = "S"
  }
  attribute {
    name = "tier"
    type = "S"
  }
}