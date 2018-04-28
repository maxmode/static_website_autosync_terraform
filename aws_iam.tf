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
