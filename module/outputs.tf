output "invoke_url" {
  description = "API Gateway Invoke URL"

  value = module.service-apigateway.invoke_url
}

output "vpc_endpoint_urls" {
  description = "API Gateway VPC Endpoint URLs"

  value = module.service-apigateway.vpc_endpoint_urls
}