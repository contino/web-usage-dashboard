module "elasticsearch" {
  source                = "./modules/es"
  domain                = var.project_name
  allowed_ip            = var.allowed_ip
  tag_domain            = var.project_name
}

module "lambda" {
  source                = "./modules/lambda"
  lambda_description    = var.project_name
  lambda_function_name  = var.project_name
  lambda_zip_path       = "../lambda.zip"
  lambda_timeout        = 900
  lambda_memory_size    = 512

  lambda_environment_variables = {
    REGION = "eu-west-2"
    ES_HOST = module.elasticsearch.endpoint
    ES_INDEX = "web-logs"
    ES_INDEX_TYPE = "_doc"
    AWS_SERVICE = "es"
  }
}

module "s3" {
  source = "./modules/s3"
  lambda_function_arn = module.lambda.lambda_arn
  project_name = var.project_name
}