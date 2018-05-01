variable "domain" {}
variable "certificate_arn" {}
variable "document_root" {}
variable "enabled" {}
variable "route53_zone_id" {}
variable "cache_ttl" {}
output "bucket" {
  value = "${aws_s3_bucket.s3_website.bucket}"
}
output "cloudfront_domain" {
  value = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
}