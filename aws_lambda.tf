resource "aws_lambda_function" "static_website_deploy" {
  function_name    = "static_website_deploy_${replace(var.domain, ".", "_")}_tf"
  role             = "${aws_iam_role.iam_static_website_deploy_role.arn}"
  handler          = "unzip.lambda_handler"
  filename         = "${data.archive_file.static_website_deploy_zip.output_path}"
  source_code_hash = "${data.archive_file.static_website_deploy_zip.output_base64sha256}"
  runtime          = "python3.6"
  timeout          = "10"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.static_website_deploy.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.s3_website.arn}"
}
