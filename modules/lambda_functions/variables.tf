variable "infra_env" {
  type        = string
  description = "Current environment"
}

variable "region" {
  type        = string
  description = "Region used"
}

variable "coffee_pool_table_name" {
  type        = string
  description = "Dynamodb coffee pool table name"
}
