data "archive_file" "lambda-payload-upload" {
  type        = "zip"
  source_file = "./lambda-functions/S3UploadHandler.py"
  output_path = "lambda-upload.zip"
}

resource "aws_cloudwatch_log_group" "Imagehandler-lambda-upload-LogGroup" {
  name = var.cloudwatch-log-group-upload
}

resource "aws_lambda_function" "image-upload-lambda" {
  function_name    = var.lambda-upload-name
  filename         = "lambda-upload.zip"
  handler          = var.lambda-handler-upload
  runtime          = var.runtime
  source_code_hash = data.archive_file.lambda-payload-upload.output_base64sha256
  memory_size      = 2048
  timeout          = 30
  role             = aws_iam_role.lambda-exec-upload.arn
  depends_on = [
    aws_cloudwatch_log_group.Imagehandler-lambda-upload-LogGroup
  ]
}

# Adding S3 bucket as trigger to my lambda and giving the permissions

resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = aws_s3_bucket.website.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.image-upload-lambda.arn
    events              = ["s3:ObjectCreated:*"]

  }
}

resource "aws_lambda_permission" "S3-invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image-upload-lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.website.id}"
}