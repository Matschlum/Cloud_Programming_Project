# Create S3 Bucket to store the website
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket

resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name
}

# Define the ownership of the bucket
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls
resource "aws_s3_bucket_ownership_controls" "ownership_for_website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Make the bucket public
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl

resource "aws_s3_bucket_public_access_block" "access_for_website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "acl_for_website_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.ownership_for_website_bucket,
    aws_s3_bucket_public_access_block.access_for_website_bucket,
  ]

  bucket = aws_s3_bucket.website_bucket.id
  acl    = "public-read"
}

# Add the websites as objects to bucket
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object

resource "aws_s3_object" "wesbite_html" {
  depends_on   = [aws_s3_bucket_acl.acl_for_website_bucket]
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
  acl          = "public-read"
}

resource "aws_s3_object" "error_html" {
  depends_on   = [aws_s3_bucket_acl.acl_for_website_bucket]
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "error.html"
  source       = "error.html"
  content_type = "text/html"
  acl          = "public-read"
}

# Website configuration
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}

# Set up CloudFront
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  # Connection with the S3 bucket
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.website_bucket.bucket}"
  }
  # Basic settings for the CloudFront
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Cloud Programming - Static Website"
  default_root_object = "index.html"

  # Sets cache behavior for the website
  default_cache_behavior {
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]

    target_origin_id = "S3-${aws_s3_bucket.website_bucket.bucket}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    # Redirects http requests to https
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  # Use PriceClass_All for lowest latency and highest data transfer
  # PriceClass_100 is the cheaptest version 
  price_class = "PriceClass_100"

  # Used if there is a custom domain available, otherwise do not use it
  # aliases = ["www.cloudprogrammingstaticwebsite.com"]

  # Disable geo-restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Route 53 is not needed since there is no custom domain like www.cloudprogrammingstaticwebsite.com
# for a custom domain, then Route 53 can be setup using
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone
#
# resource "aws_route53_zone" "main" {
#   name = "www.cloudprogrammingstaticwebsite.com"
# }
# and using
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
#
# resource "aws_route53_record" "www" {
#   zone_id = aws_route53_zone.primary.zone_id 
#   name    = "www.example.com"
#   type    = "A"
#   ttl     = 300
#   records = [aws_eip.lb.public_ip]
# }
