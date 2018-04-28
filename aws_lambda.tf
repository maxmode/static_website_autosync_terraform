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

resource "aws_iam_role" "iam_static_website_deploy_role" {
  name = "iam_static_website_deploy_${replace(var.domain, ".", "_")}_tf"
  assume_role_policy = "${file("${path.module}/policy/lambda_role.json")}"
}

resource "aws_iam_policy" "iam_static_website_deploy_policy" {
  name = "iam_static_website_${replace(var.domain, ".", "_")}_tf"
  policy = "${replace(file("${path.module}/policy/lambda_s3_policy.json"),"mybucket","${aws_s3_bucket.s3_website.bucket}")}"
}

resource "aws_iam_role_policy_attachment" "iam_static_website_role-attach" {
  role       = "${aws_iam_role.iam_static_website_deploy_role.name}"
  policy_arn = "${aws_iam_policy.iam_static_website_deploy_policy.arn}"
}

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
