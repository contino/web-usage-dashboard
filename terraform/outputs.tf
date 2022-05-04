output "s3_bucket_name" {
    value = module.s3.bucket_name
}

output "kibana_endpoint" {
    value = "https://${module.elasticsearch.kibana_endpoint}"
}

output "elasticsearch_endpoint" {
    value = "https://${module.elasticsearch.endpoint}"
}

output "lambda_arn_endpoint" {
    value = module.lambda.lambda_arn
}