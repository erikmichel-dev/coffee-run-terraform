variable "infra_env" {
  type        = string
  description = "Current environment"
  default     = "dev"
}

variable "region" {
  type        = string
  description = "Region used"
  default     = "eu-south-2"
}