data "archive_file" "static_website_deploy_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda/static_website_deploy_${replace(var.domain, ".", "_")}_tf.zip"

  source {
    content  = "${replace(file("${path.module}/lambda/unzip.py"),"my-bucket","${aws_s3_bucket.s3_website.bucket}")}"
    filename = "unzip.py"
  }

  source {
    content  = "${file("${path.module}/lambda/magic.py")}"
    filename = "magic.py"
  }
}

data "archive_file" "website_zip" {
  type        = "zip"
  source_dir  = "${var.document_root}"
  output_path = "${path.module}/output/${aws_s3_bucket.s3_website.bucket}.zip"
}
