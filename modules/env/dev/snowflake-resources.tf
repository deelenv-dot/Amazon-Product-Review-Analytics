resource "snowflake_database" "capstone_db" {
  name    = upper(var.snowflake_database)
  comment = "Terraform-created DB for capstone project"
}

resource "snowflake_schema" "capstone_schema" {
  database = snowflake_database.capstone_db.name
  name     = upper(var.snowflake_schema)
  comment  = "Schema for capstone raw data"
}
