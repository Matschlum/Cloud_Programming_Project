# Website Endpoint output:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration

output "websiteendpoint_s3" {
  value = aws_s3_bucket_website_configuration.website_config.website_endpoint
}

output "websiteendpoint_cloudfront" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}