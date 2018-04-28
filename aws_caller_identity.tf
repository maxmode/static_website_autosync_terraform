variable "domain" {}
variable "certificate_arn" {}
variable "document_root" {}
variable "enabled" {}
variable "route53_zone_id" {}
variable "aws_region" {}
variable "access_key" {}
variable "secret_key" {}
variable "cache_ttl" {}

provider "aws" {
  region = "${var.aws_region}"
  version = "~> 1.12"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}
data "aws_caller_identity" "current" {}
