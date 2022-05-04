

resource "aws_lambda_function" "lambda" {
  function_name = var.lambda_function_name
  description   = var.lambda_description

  filename         = var.lambda_zip_path
  handler          = var.lambda_handler
  source_code_hash = base64sha256(filebase64(var.lambda_zip_path))
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size
  reserved_concurrent_executions = 10

  role             = aws_iam_role.lambda_execution_role.arn
  kms_key_arn      = data.aws_kms_alias.lambda.target_key_arn


  dynamic "environment" {
    for_each = var.lambda_environment_variables[*]
    content {
      variables = environment.value
    }
  }

  tracing_config {
    mode = "Active"
  }

  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }

}

resource "aws_sqs_queue" "dlq" {
  name = "${var.lambda_function_name}-DLQ"
}

data "aws_kms_alias" "lambda" {
  name = "alias/aws/lambda"
}
