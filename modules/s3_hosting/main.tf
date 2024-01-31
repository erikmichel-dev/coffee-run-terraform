# locals {
#   s3_origin_id   = "${var.s3_name}-origin"
#   s3_domain_name = "${var.s3_name}.s3-website-${var.region}.amazonaws.com"
# }

resource "aws_cloudfront_distribution" "this" {
  enabled = true
  default_root_object = "index.html"

  origin {
    origin_id   = aws_s3_bucket.this.bucket_regional_domain_name
    domain_name = aws_s3_bucket.this.bucket_regional_domain_name
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

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  price_class = "PriceClass_100"
}

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "${aws_s3_bucket.this.bucket}"
  description                       = "${aws_s3_bucket.this.bucket} Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


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
