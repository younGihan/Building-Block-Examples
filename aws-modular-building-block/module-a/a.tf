resource "aws_s3_bucket_object" "object" {
  bucket = var.bucket_name
  key    = "test-file-module-a"
  content_base64 = "dGhpcyBpcyBhIHRlc3QgZmlsZQ=="
}