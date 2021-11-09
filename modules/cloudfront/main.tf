locals{
  s3_origin_id = "cf-s3"
  alb_origin_id = "cf-alb"
}

resource "aws_cloudfront_distribution" "cf_distribution" {
  enabled = true
  comment = "CF Distribution for ${var.project_name}"
  price_class = var.cf_price_class
  is_ipv6_enabled = true

  # S3 STATIC CONTENT
  origin {
    origin_id   = local.s3_origin_id
    domain_name = var.s3_bucket_dns

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cf_oai_s3_bucket.cloudfront_access_identity_path
    }
  }

  # ALB
  origin {
    origin_id   = local.alb_origin_id
    domain_name = var.alb_public_dns

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2", "SSLv3"]
    }
  }

  tags = {
    Name = "CF ${var.project_name} ${terraform.workspace}"
    Environment = "${terraform.workspace}"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.alb_origin_id

    forwarded_values {
      headers = ["*"]
      query_string = true

      cookies {
        forward = "all"
      }
    }

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
    viewer_protocol_policy = "https-only"
  }

  ordered_cache_behavior {
    path_pattern     = "/static/*"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }
}

resource "aws_cloudfront_origin_access_identity" "cf_oai_s3_bucket" {
  comment = "CF OAI for S3"
}