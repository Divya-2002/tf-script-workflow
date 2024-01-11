resource "aws_lambda_function" "my_lambda_function" {
  function_name = "MyLambdaFunction"
  filename      = "lambda_function_payload.zip" 
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  # IAM role for Lambda execution
  role = aws_iam_role.lambda_role.arn

  # Specify the S3 bucket and object prefix for the Lambda deployment package
  source_code_hash = filebase64sha256("lambda_function_payload.zip")
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

}

// Example: Lambda triggers on S3 bucket event
resource "aws_lambda_permission" "s3_trigger_permission" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.my_bucket.arn
}
