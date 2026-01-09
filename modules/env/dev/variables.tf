variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "snowflake_account" {
  description = "Snowflake account identifier"
  type        = string
}

variable "snowflake_user" {
  description = "Snowflake username"
  type        = string
}

variable "snowflake_password" {
  description = "Snowflake password (unused when using key-pair auth)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "snowflake_role" {
  description = "Snowflake role"
  type        = string
  default     = "ACCOUNTADMIN"
}

variable "snowflake_warehouse" {
  description = "Snowflake warehouse"
  type        = string
  default     = ""
}

variable "snowflake_private_key" {
  description = "Snowflake private key (PEM) for key-pair auth"
  type        = string
  sensitive   = true
}

variable "snowflake_database" {
  description = "Snowflake database name to create"
  type        = string
  default     = "CAPSTONE_AMAZON_DB"
}

variable "snowflake_schema" {
  description = "Snowflake schema name to create"
  type        = string
  default     = "CAPSTONE_AMAZON_RAW"
}
