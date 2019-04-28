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

data "aws_iam_policy_document" "sts" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "lambda:GetFunction",
    ]

    resources = [
      "${aws_lambda_function.lambda_index_files.arn}:*",
    ]
  }
}

resource "aws_iam_role_policy" "lambda_index_files_policy" {
  provider       = "aws.edge"
  name   = "${replace(var.domain, ".", "-")}-lambda_index_files-policy"
  role   = "${aws_iam_role.lambda_index_files.id}"
  policy = "${data.aws_iam_policy_document.this.json}"
}

resource "aws_iam_role" "lambda_index_files" {
  provider           = "aws.edge"
  name               = "${replace(var.domain, ".", "-")}-lambda_index_files-role"
  assume_role_policy = "${data.aws_iam_policy_document.sts.json}"
}