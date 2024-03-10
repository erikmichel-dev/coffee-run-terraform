variable "region" {
  description = "Region used"
  type = string
}

variable "s3_name" {
  description = "S3 bucket name"
  type = string
}

variable "domain_name" {
  description = "Domain used for the hosted zone"
  type = string
}

variable "is_prod" {
  description = "Conditional for resources that have to be built in prod only"
  type = bool
}