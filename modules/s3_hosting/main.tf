provider "aws" {
  region = "us-east-1"
  alias  = "use1"
}

### Cloudfront Distribution

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    origin_id                = aws_s3_bucket.this.bucket_regional_domain_name
    domain_name              = aws_s3_bucket.this.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  default_cache_behavior {

    target_origin_id = aws_s3_bucket.this.bucket_regional_domain_name
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  aliases = var.is_prod ? [var.domain_name] : []
  dynamic "viewer_certificate" {
    for_each = var.is_prod ? [1] : []

    content {
      acm_certificate_arn            = aws_acm_certificate.this[0].arn
      ssl_support_method             = "sni-only"
      minimum_protocol_version       = "TLSv1.2_2021"
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.is_prod ? [] : [1]

    content {
      cloudfront_default_certificate = true
    }
  }

  price_class = "PriceClass_100"

  # Needs certificate to be validated first
  depends_on = [
    aws_acm_certificate_validation.this
  ]
}

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = aws_s3_bucket.this.bucket
  description                       = "${aws_s3_bucket.this.bucket} Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

### S3 Bucket

resource "random_id" "this" {
  byte_length = 8
}

resource "aws_s3_bucket" "this" {
  bucket = "${var.s3_name}-${random_id.this.hex}"
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = jsonencode({
    "Version" : "2008-10-17",
    "Id" : "PolicyForCloudFrontPrivateContent",
    "Statement" : [
      {
        "Sid" : "AllowCloudFrontServicePrincipal",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : "s3:GetObject",
        "Resource" : "${aws_s3_bucket.this.arn}/*",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : "${aws_cloudfront_distribution.this.arn}"
          }
        }
      }
    ]
  })
}

### ACM Certificate

resource "aws_acm_certificate" "this" {
  count = var.is_prod ? 1 : 0
  provider          = aws.use1
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "this" {
  provider                = aws.use1
  for_each                = aws_route53_record.validation
  certificate_arn         = aws_acm_certificate.this[0].arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}

### Route53 Hosted zone

resource "aws_route53_zone" "this" {
  count = var.is_prod ? 1 : 0
  name = var.domain_name
}

resource "aws_route53_record" "validation" {
  for_each = var.is_prod ? {
    for dvo in aws_acm_certificate.this[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  zone_id = aws_route53_zone.this[0].zone_id
  allow_overwrite = true
  name = each.value.name
  records = [each.value.record]
  type = each.value.type
  ttl = 60
}

resource "aws_route53_record" "root" {
  count = var.is_prod ? 1 : 0
  zone_id = aws_route53_zone.this[0].zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}
