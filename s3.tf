resource "aws_s3_bucket" "picklerfinder_bucket" {
  bucket        = "picklerfinder"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.picklerfinder_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "config" {
  bucket = aws_s3_bucket.picklerfinder_bucket.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.picklerfinder_bucket.id
  policy = jsonencode({
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = ["${aws_s3_bucket.picklerfinder_bucket.arn}/*"]
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.public_access_block]
}
