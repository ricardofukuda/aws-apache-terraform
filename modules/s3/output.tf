output "s3_bucket_dns"{
  value = aws_s3_bucket.bucket_static_content.bucket_regional_domain_name
}