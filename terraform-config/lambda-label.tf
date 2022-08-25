data "archive_file" "lambda-payload-label" {
  type        = "zip"
  source_file = "./lambda-functions/getImagesByLabelHandler.py"
  output_path = "lambda-label.zip"
}

resource "aws_cloudwatch_log_group" "Imagehandler-lambda-label-LogGroup" {
  name = var.cloudwatch-log-group-label
}

resource "aws_lambda_function" "image-label-lambda" {
  function_name    = var.lambda-label-name
  filename         = "lambda-label.zip"
  handler          = var.lambda-handler-label
  runtime          = var.runtime
  source_code_hash = data.archive_file.lambda-payload-label.output_base64sha256
  memory_size      = 2048
  timeout          = 30
  role             = aws_iam_role.lambda-exec-label.arn
  depends_on = [
    aws_cloudwatch_log_group.Imagehandler-lambda-label-LogGroup
  ]
}