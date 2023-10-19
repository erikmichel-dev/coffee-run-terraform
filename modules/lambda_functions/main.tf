# Coffe of the day

data "archive_file" "daily_coffee" {
  type        = "zip"
  source_dir  = "${path.module}/daily_coffee/"
  output_path = "${path.module}/daily_coffee/daily_coffee.zip"
}

resource "aws_lambda_function" "daily_coffee" {
  filename         = data.archive_file.daily_coffee.output_path
  source_code_hash = data.archive_file.daily_coffee.output_base64sha256
  role             = aws_iam_role.lambda.arn
  function_name    = "daily_coffee-${var.infra_env}"
  handler          = "daily_coffee.lambda_handler"
  runtime          = "python3.11"
  depends_on       = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}
