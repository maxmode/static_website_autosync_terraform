resource "aws_route53_record" "cf_distribution" {
  count = "${var.enabled}"
  zone_id = "${var.route53_zone_id}"
  name    = "${var.domain}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = true
  }
}