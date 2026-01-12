resource "aws_s3_object" "glue_download_script" {
  bucket = aws_s3_bucket.raw.id
  key    = "scripts/glue/download_from_url.py"
  source = "../../../glue_jobs/download_from_url.py"
  etag   = filemd5("../../../glue_jobs/download_from_url.py")
}

resource "aws_s3_object" "glue_flatten_script" {
  bucket = aws_s3_bucket.raw.id
  key    = "scripts/glue/flatten_jsonl_to_parquet.py"
  source = "../../../glue_jobs/flatten_jsonl_to_parquet.py"
  etag   = filemd5("../../../glue_jobs/flatten_jsonl_to_parquet.py")
}
