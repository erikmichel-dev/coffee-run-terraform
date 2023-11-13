### ROLES

# Lambda function "daily_coffee" role
resource "aws_iam_role" "daily_coffee" {
  name               = "lambda_daily_coffee_role-${var.infra_env}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "daily_coffee_cloudwatch_logs" {
  role       = aws_iam_role.daily_coffee.name
  policy_arn = aws_iam_policy.cloudwatch_logs.arn
}

# Lambda function "populate_coffee_pool" role
resource "aws_iam_role" "populate_coffee_pool" {
  name               = "lambda_populate_coffee_pool_role-${var.infra_env}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "populate_coffee_pool_cloudwatch_logs" {
  role       = aws_iam_role.populate_coffee_pool.name
  policy_arn = aws_iam_policy.cloudwatch_logs.arn
}
resource "aws_iam_role_policy_attachment" "populate_coffee_pool_batchwrite_coffee_pool" {
  role       = aws_iam_role.populate_coffee_pool.name
  policy_arn = aws_iam_policy.batchwrite_coffee_pool.arn
}

### POLICIES

# Cloudwatch create logs access policy
resource "aws_iam_policy" "cloudwatch_logs" {

  name        = "terraform_cloudwatch_logs_policy-${var.infra_env}"
  path        = "/"
  description = "AWS IAM Policy for cloudwatch logs access"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# Dynamodb table "coffee_pool" batch write access
resource "aws_iam_policy" "batchwrite_coffee_pool" {

  name        = "terraform_dynamodb_batchwrite_policy-${var.infra_env}"
  path        = "/"
  description = "AWS IAM Policy for coffee_pool table batch write access"
  policy      = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Action": "dynamodb:BatchWriteItem",
			"Resource": "arn:aws:dynamodb:*:*:table/coffee_pool*",
			"Effect": "Allow"
		}
	]
}
EOF
}
