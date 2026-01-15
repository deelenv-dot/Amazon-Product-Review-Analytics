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

variable "snowflake_storage_integration_name" {
  description = "Snowflake storage integration name"
  type        = string
  default     = "CAPSTONE_S3_INT"
}

variable "snowflake_stage_name" {
  description = "Snowflake external stage name"
  type        = string
  default     = "CAPSTONE_S3_STAGE"
}

variable "snowflake_file_format_name" {
  description = "Snowflake file format name"
  type        = string
  default     = "CAPSTONE_PARQUET_FF"
}

variable "snowflake_iam_user_arn" {
  description = "Snowflake IAM user ARN from DESC INTEGRATION (leave empty on first apply)"
  type        = string
  default     = ""
}

variable "snowflake_external_id" {
  description = "Snowflake external ID from DESC INTEGRATION (leave empty on first apply)"
  type        = string
  default     = ""
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

variable "reviews_url" {
  description = "Source URL for reviews dataset (jsonl.gz)"
  type        = string
}

variable "meta_url" {
  description = "Source URL for metadata dataset (jsonl.gz)"
  type        = string
}

variable "sns_email" {
  description = "Email address for SNS notifications"
  type        = string
}
