
# Lambda Settings

variable "lambda_function_name" {
  description = "The name to use for the lambda function"
  type        = string
}

variable "lambda_description" {
  description = "The description to use for the AWS Lambda"
  type        = string
}

variable "lambda_handler" {
  description = "The name of the handler to use for the lambda function"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "lambda_zip_path" {
  description = "The location where the generated zip file should be stored"
  type        = string
}

variable "lambda_runtime" {
  description = "The runtime to use for the lambda function"
  type        = string
  default     = "python3.8"
}

variable "lambda_timeout" {
  description = "The timeout period to use for the lambda function"
  default     = 30
}

variable "lambda_memory_size" {
  description = "The amount of memory to use for the lambda function"
  default     = 128
}

variable "lambda_environment_variables" {
  description = "Environment variables to be provided to the lambda function."
  type        = map(string)
  default     = null
}

variable "tags" {
  description = "AWS tags to use on created infrastructure components"
  type        = map(string)
  default     = {}
}
