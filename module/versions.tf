module "infra" {
  source = "../../modules/infra"

  # Keep the existing S3 inputs here.

  api_gateway_name = "REPLACE_WITH_EXISTING_API_NAME"

  api_backends = {
    externalaccounts = {
      nlb_dns_name  = "REPLACE_WITH_EXISTING_NLB_DNS"
      vpc_link_name = "REPLACE_WITH_EXISTING_VPC_LINK_NAME"
    }
  }

  allowed_external_vpc_endpoint_ids = [
    "vpce-REPLACE_WITH_REAL_ID"
  ]
}