variable "api_gateway_name" {
  description = "Name of the existing API Gateway"
  type        = string
}

variable "api_version" {
  description = "OpenAPI version metadata"
  type        = string
  default     = "1.0.0"
}

variable "api_backends" {
  description = "Namespace to existing EKS NLB and VPC Link mapping"

  type = map(object({
    nlb_dns_name  = string
    vpc_link_name = string
  }))
}

variable "allowed_external_vpc_endpoint_ids" {
  description = "Allowed VPC endpoint IDs for private API Gateway access"
  type        = list(string)
}