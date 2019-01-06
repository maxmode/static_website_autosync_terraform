variable "domain" {}
variable "certificate_arn" {}
variable "document_root" {}
variable "enabled" {}
variable "route53_zone_id" {}
variable "cache_ttl" {}
variable "cache_control_default" {
  default = "public, max-age=2592000"
}
variable "cache_control_text_html" {
  default = "public, s-maxage=900"
}
output "bucket" {
  value = "${aws_s3_bucket.s3_website.bucket}"
}
output "bucket_deploy_function" {
  value = "${aws_lambda_function.static_website_deploy.arn}"
}
output "bucket_deploy_filename" {
  value = "${aws_s3_bucket_object.website.key}"
}
output "cloudfront_domain" {
  value = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
}