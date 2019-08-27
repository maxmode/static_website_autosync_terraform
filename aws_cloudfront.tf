resource "aws_cloudfront_origin_access_identity" "identity" {
  comment = "Access identity for hosted zone ${var.route53_zone_id}"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.s3_website.bucket_domain_name}"
    origin_id   = "myS3Origin"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.identity.id}"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.domain}"
  default_root_object = "index.html"

  aliases = ["${var.domain}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "myS3Origin"

    forwarded_values {
      headers = "${var.cf_forwarded_headers}"
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl                = "${var.cache_ttl}"
    default_ttl            = "${var.cache_ttl}"
    max_ttl                = "${var.cache_ttl}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn = "${var.certificate_arn}"
    ssl_support_method = "sni-only"
  }

  logging_config {
    bucket = "${aws_s3_bucket.s3_website_logging.bucket}.s3.amazonaws.com"
    prefix = "cf-${var.domain}/"
  }

  custom_error_response {
    error_code = 403
    response_code = 404
    error_caching_min_ttl = 300
    response_page_path = "${var.cf_404_page}"
  }
}