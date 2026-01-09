resource "aws_s3_object" "placeholder" {
  bucket = aws_s3_bucket.raw.id
  key    = "raw/placeholder.txt"
  source = "../../../data/placeholder.txt"
  etag   = filemd5("../../../data/placeholder.txt")
}
