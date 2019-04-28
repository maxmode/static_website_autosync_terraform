resource "aws_lambda_function" "static_website_deploy" {
  function_name    = "static_website_deploy_${replace(var.domain, ".", "_")}_tf"
  role             = "${aws_iam_role.iam_static_website_deploy_role.arn}"
  handler          = "unzip.lambda_handler"
  filename         = "${data.archive_file.static_website_deploy_zip.output_path}"
  source_code_hash = "${data.archive_file.static_website_deploy_zip.output_base64sha256}"
  runtime          = "python3.6"
  timeout          = "300"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.static_website_deploy.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.s3_website.arn}"
}

resource "aws_lambda_function" "lambda_index_files" {
  function_name    = "lambda_index_files_${replace(var.domain, ".", "_")}_tf"
  provider         = "aws.edge"
  role             = "${aws_iam_role.lambda_index_files.arn}"
  handler          = "index.handler"
  filename         = "${data.archive_file.lambda_index_files.output_path}"
  source_code_hash = "${data.archive_file.lambda_index_files.output_base64sha256}"
  runtime          = "nodejs8.10"
  timeout          = "5"
}

resource "aws_lambda_permission" "allow_cloudfront" {
  statement_id   = "AllowExecutionFromCloudFront"
  provider       = "aws.edge"
  action         = "lambda:GetFunction"
  function_name  = "${aws_lambda_function.lambda_index_files.function_name}"
  principal      = "edgelambda.amazonaws.com"
}