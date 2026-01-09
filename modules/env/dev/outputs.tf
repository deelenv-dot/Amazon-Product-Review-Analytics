output "bucket_name" {
  value       = aws_s3_bucket.raw.bucket
  description = "S3 bucket name for the capstone raw zone"
}

output "snowflake_database" {
  value       = snowflake_database.capstone_db.name
  description = "Snowflake database created"
}

output "snowflake_schema" {
  value       = snowflake_schema.capstone_schema.name
  description = "Snowflake schema created"
}
