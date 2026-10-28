data "aws_api_gateway_vpc_link" "eks_nlb_vpc_links" {
  for_each = var.api_backends

  name = each.value.vpc_link_name
}