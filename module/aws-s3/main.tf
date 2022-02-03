resource "aws_s3_bucket" "sample_bucket" {
  bucket = var.bucket_id
  acl    = "private"

  tags = {
    Name        = "${var.env_prefix}-bucket"
    Environment = var.env_prefix
  }
  versioning {
    enabled = true
  }
}