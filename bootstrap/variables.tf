variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Base name for S3 bucket"
  type        = string
  default     = "capstone-tf-state"
}

variable "dynamodb_table" {
  description = "DynamoDB table name for state locking"
  type        = string
  default     = "capstone-terraform-locks"
}
