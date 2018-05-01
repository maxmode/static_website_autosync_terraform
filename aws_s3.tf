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

resource "aws_s3_bucket_object" "website" {
  bucket = "${aws_s3_bucket.s3_website.bucket}"
  key    = "website.zip"
  source = "${data.archive_file.website_zip.output_path}"
  etag   = "${data.archive_file.website_zip.output_md5}"
}