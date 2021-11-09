

resource "aws_s3_bucket" "bucket_static_content" {
  bucket = "${var.project_name}-static-content-123456-${terraform.workspace}"
  acl    = "private"

  force_destroy = true

  tags = {
    Name = "${var.project_name}-static-content-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_static_content_public_access_block" {
  bucket = aws_s3_bucket.bucket_static_content.id

  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_object" "s3_object" {
  bucket = aws_s3_bucket.bucket_static_content.id
  key    = "static/cat.png"
  source = "cat.png"
  etag = filemd5("cat.png")
}


resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.bucket_static_content.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "my bucket policy"
    Statement = [
      {
        Sid       = "policy1"
        Effect    = "Allow"
        Principal = {
          AWS = "${var.cf_origin_access_identity_iam_arn}"
        }
        Action    = ["s3:GetObject"]
        Resource = [
          "${aws_s3_bucket.bucket_static_content.arn}/*"
        ]
      },
      {
        Sid       = "policy2"
        Effect    = "Allow"
        Principal = {
          AWS = "${var.cf_origin_access_identity_iam_arn}"
        }
        Action    = ["s3:ListBucket"]
        Resource = [
          "${aws_s3_bucket.bucket_static_content.arn}"
        ]
      }
    ]
  })
}