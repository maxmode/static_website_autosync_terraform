data "archive_file" "static_website_deploy_zip" {
  type        = "zip"
  output_path = "${path.module}/static_website_deploy_${replace(var.domain, ".", "_")}_tf.zip"

  source {
    content  = "${replace(replace(replace(file("${path.module}/lambda/unzip.py"),"my-bucket","${aws_s3_bucket.s3_website.bucket}"),"cache_control_default","${var.cache_control_default}"),"cache_control_text_html","${var.cache_control_text_html}")}"
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


data "archive_file" "lambda_index_files" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_index_files"
  output_path = "${path.module}/lambda_index_files.zip"
}