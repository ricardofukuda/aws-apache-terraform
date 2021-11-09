output "cf_origin_access_identity_iam_arn"{
  value = aws_cloudfront_origin_access_identity.cf_oai_s3_bucket.iam_arn
}

output "domain_name"{
  value = aws_cloudfront_distribution.cf_distribution.domain_name
}

output "hosted_zone_id"{
  value = aws_cloudfront_distribution.cf_distribution.hosted_zone_id
}