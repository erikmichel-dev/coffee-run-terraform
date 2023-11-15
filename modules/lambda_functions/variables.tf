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

variable "tier_list_table_name" {
  type        = string
  description = "Dynamodb tier list table name"
}
