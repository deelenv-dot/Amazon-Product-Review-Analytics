locals {
  reviews_url = "https://mcauleylab.ucsd.edu/public_datasets/data/amazon_2023/raw/review_categories/Amazon_Fashion.jsonl.gz"
  meta_url    = "https://mcauleylab.ucsd.edu/public_datasets/data/amazon_2023/raw/meta_categories/meta_Amazon_Fashion.jsonl.gz"

  reviews_key = "raw/amazon_2023/review_categories/Amazon_Fashion.jsonl.gz"
  meta_key    = "raw/amazon_2023/meta_categories/meta_Amazon_Fashion.jsonl.gz"

  reviews_flattened = "flattened/amazon_2023/reviews/"
  meta_flattened    = "flattened/amazon_2023/meta/"

  meta_cleaned_key = "raw/amazon_2023/meta_categories/clean/meta_Amazon_Fashion.jsonl.gz"
}

resource "aws_glue_job" "download_reviews" {
  name     = "capstone-download-reviews-${random_id.suffix.hex}"
  role_arn = aws_iam_role.glue_job.arn

  command {
    name            = "pythonshell"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket.raw.bucket}/${aws_s3_object.glue_download_script.key}"
  }

  glue_version = "1.0"
  max_capacity = 1.0
  timeout      = 2880

  default_arguments = {
    "--job-language" = "python"
    "--TempDir"      = "s3://${aws_s3_bucket.raw.bucket}/tmp/"
    "--source_url"   = local.reviews_url
    "--s3_bucket"    = aws_s3_bucket.raw.bucket
    "--s3_key"       = local.reviews_key
  }
}

resource "aws_glue_job" "download_meta" {
  name     = "capstone-download-meta-${random_id.suffix.hex}"
  role_arn = aws_iam_role.glue_job.arn

  command {
    name            = "pythonshell"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket.raw.bucket}/${aws_s3_object.glue_download_script.key}"
  }

  glue_version = "1.0"
  max_capacity = 1.0
  timeout      = 2880

  default_arguments = {
    "--job-language" = "python"
    "--TempDir"      = "s3://${aws_s3_bucket.raw.bucket}/tmp/"
    "--source_url"   = local.meta_url
    "--s3_bucket"    = aws_s3_bucket.raw.bucket
    "--s3_key"       = local.meta_key
  }
}

resource "aws_glue_job" "clean_meta" {
  name     = "capstone-clean-meta-${random_id.suffix.hex}"
  role_arn = aws_iam_role.glue_job.arn

  command {
    name            = "pythonshell"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket.raw.bucket}/${aws_s3_object.glue_clean_script.key}"
  }

  glue_version = "1.0"
  max_capacity = 1.0
  timeout      = 2880

  default_arguments = {
    "--job-language"  = "python"
    "--TempDir"       = "s3://${aws_s3_bucket.raw.bucket}/tmp/"
    "--source_bucket" = aws_s3_bucket.raw.bucket
    "--source_key"    = local.meta_key
    "--target_key"    = local.meta_cleaned_key
  }
}

resource "aws_glue_job" "flatten_reviews" {
  name     = "capstone-flatten-reviews-${random_id.suffix.hex}"
  role_arn = aws_iam_role.glue_job.arn

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.raw.bucket}/${aws_s3_object.glue_flatten_script.key}"
  }

  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 2
  timeout           = 2880

  default_arguments = {
    "--job-language"   = "python"
    "--TempDir"        = "s3://${aws_s3_bucket.raw.bucket}/tmp/"
    "--source_s3_path" = "s3://${aws_s3_bucket.raw.bucket}/${local.reviews_key}"
    "--target_s3_path" = "s3://${aws_s3_bucket.raw.bucket}/${local.reviews_flattened}"
  }
}

resource "aws_glue_job" "flatten_meta" {
  name     = "capstone-flatten-meta-${random_id.suffix.hex}"
  role_arn = aws_iam_role.glue_job.arn

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.raw.bucket}/${aws_s3_object.glue_flatten_script.key}"
  }

  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 2
  timeout           = 2880

  default_arguments = {
    "--job-language"   = "python"
    "--TempDir"        = "s3://${aws_s3_bucket.raw.bucket}/tmp/"
    "--source_s3_path" = "s3://${aws_s3_bucket.raw.bucket}/${local.meta_cleaned_key}"
    "--target_s3_path" = "s3://${aws_s3_bucket.raw.bucket}/${local.meta_flattened}"
  }
}
