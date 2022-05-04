
resource "aws_s3_bucket" "data_bucket" {
  # Creates a unique bucket name beginning with project_name
  bucket_prefix = "${var.project_name}-"

  # for terraform destroy to succeed when bucket is not empty
  force_destroy = true

}

resource "aws_s3_bucket" "s3log_bucket" {
  # Creates a unique bucket name beginning with project_name
  bucket_prefix = "${var.project_name}-s3logs"

  # for terraform destroy to succeed when bucket is not empty
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  bucket = aws_s3_bucket.data_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
    }
  }
}


resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.data_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "s3_logging" {
  bucket = aws_s3_bucket.data_bucket.id

  target_bucket = aws_s3_bucket.s3log_bucket.id
  target_prefix = "${var.project_name}-s3logs"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.data_bucket.id

  lambda_function {
    lambda_function_arn = var.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".log"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.data_bucket.arn
}

resource "aws_s3_bucket_public_access_block" "block1" {
  bucket = aws_s3_bucket.data_bucket.id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket_public_access_block" "block2" {
  bucket = aws_s3_bucket.s3log_bucket.id

  block_public_acls   = true
  block_public_policy = true
}