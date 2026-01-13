data "aws_caller_identity" "current" {}

locals {
  flattened_prefix = "flattened/amazon_2023/"
}

data "aws_iam_policy_document" "snowflake_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [
        var.snowflake_iam_user_arn != "" ? var.snowflake_iam_user_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
    actions = ["sts:AssumeRole"]

    dynamic "condition" {
      for_each = var.snowflake_external_id != "" ? [1] : []
      content {
        test     = "StringEquals"
        variable = "sts:ExternalId"
        values   = [var.snowflake_external_id]
      }
    }
  }
}

resource "aws_iam_role" "snowflake_integration" {
  name               = "capstone-snowflake-int-${random_id.suffix.hex}"
  assume_role_policy = data.aws_iam_policy_document.snowflake_assume_role.json
}

data "aws_iam_policy_document" "snowflake_s3_read" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]
    resources = ["${aws_s3_bucket.raw.arn}/${local.flattened_prefix}*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.raw.arn]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["${local.flattened_prefix}*"]
    }
  }
}

resource "aws_iam_role_policy" "snowflake_s3_read" {
  name   = "capstone-snowflake-s3-read"
  role   = aws_iam_role.snowflake_integration.id
  policy = data.aws_iam_policy_document.snowflake_s3_read.json
}

resource "snowflake_storage_integration" "s3_int" {
  name                      = upper(var.snowflake_storage_integration_name)
  type                      = "EXTERNAL_STAGE"
  storage_provider          = "S3"
  enabled                   = true
  storage_aws_role_arn       = aws_iam_role.snowflake_integration.arn
  storage_allowed_locations = ["s3://${aws_s3_bucket.raw.bucket}/${local.flattened_prefix}"]
  comment                   = "S3 integration for capstone flattened data"
}

resource "snowflake_file_format" "parquet" {
  name     = upper(var.snowflake_file_format_name)
  format_type = "PARQUET"
  database = snowflake_database.capstone_db.name
  schema   = snowflake_schema.capstone_schema.name
}

resource "snowflake_stage" "s3_stage" {
  name                = upper(var.snowflake_stage_name)
  url                 = "s3://${aws_s3_bucket.raw.bucket}/${local.flattened_prefix}"
  storage_integration = snowflake_storage_integration.s3_int.name
  file_format         = "FORMAT_NAME = ${snowflake_database.capstone_db.name}.${snowflake_schema.capstone_schema.name}.${snowflake_file_format.parquet.name}"
  database            = snowflake_database.capstone_db.name
  schema              = snowflake_schema.capstone_schema.name
}

resource "snowflake_external_table" "reviews" {
  name    = "CAPSTONE_AMAZON_REVIEWS_EXT"
  database = snowflake_database.capstone_db.name
  schema   = snowflake_schema.capstone_schema.name
  location = "@${snowflake_database.capstone_db.name}.${snowflake_schema.capstone_schema.name}.${snowflake_stage.s3_stage.name}/reviews/"
  file_format = "FORMAT_NAME = ${snowflake_database.capstone_db.name}.${snowflake_schema.capstone_schema.name}.${snowflake_file_format.parquet.name}"
  auto_refresh = false
  refresh_on_create = false

  column {
    name = "raw"
    type = "VARIANT"
    as   = "$1"
  }
}

resource "snowflake_external_table" "meta" {
  name    = "CAPSTONE_AMAZON_META_EXT"
  database = snowflake_database.capstone_db.name
  schema   = snowflake_schema.capstone_schema.name
  location = "@${snowflake_database.capstone_db.name}.${snowflake_schema.capstone_schema.name}.${snowflake_stage.s3_stage.name}/meta/"
  file_format = "FORMAT_NAME = ${snowflake_database.capstone_db.name}.${snowflake_schema.capstone_schema.name}.${snowflake_file_format.parquet.name}"
  auto_refresh = false
  refresh_on_create = false

  column {
    name = "raw"
    type = "VARIANT"
    as   = "$1"
  }
}

output "snowflake_integration_iam_user_arn" {
  value       = snowflake_storage_integration.s3_int.storage_aws_iam_user_arn
  description = "Use this value to update snowflake_iam_user_arn and IAM trust policy"
}

output "snowflake_integration_external_id" {
  value       = snowflake_storage_integration.s3_int.storage_aws_external_id
  description = "Use this value to update snowflake_external_id and IAM trust policy"
}
