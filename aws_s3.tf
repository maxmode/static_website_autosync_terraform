resource "aws_s3_bucket" "s3_website" {
  bucket = "website-${replace(var.domain,".","-")}-tf"
  acl    = "private"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags {
    Name = "Static website for ${var.domain}"
  }

  policy = "${replace(replace(file("${path.module}/policy/s3.json"),"BUCKET","website-${replace(var.domain,".","-")}-tf"),"OriginAccessIdentityARN", "${aws_cloudfront_origin_access_identity.identity.iam_arn}")}"

}

resource "aws_s3_bucket" "s3_website_logging" {
  bucket = "logs-${replace(var.domain,".","-")}-tf"
  acl    = "log-delivery-write"

  tags {
    Name = "Logs for ${var.domain}"
  }
}

resource "aws_s3_bucket_object" "website" {
  count = "${var.update_content}"
  bucket = "${aws_s3_bucket.s3_website.bucket}"
  key    = "${var.website_archive}"
  source = "${data.archive_file.website_zip.output_path}"
  etag   = "${data.archive_file.website_zip.output_md5}"
}