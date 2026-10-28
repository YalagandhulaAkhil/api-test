locals {
  api_paths = {
    for ns, config in var.api_namespaces :
    "/${ns}/{proxy+}" => {
      "security" = [
        {
          "forgerock" = []
        }
      ]

      "x-amazon-apigateway-any-method" = {
        "parameters" = [
          {
            "name"     = "proxy"
            "in"       = "path"
            "required" = true
            "schema" = {
              "type" = "string"
            }
          }
        ]

        "requestBody" = {
          "content" = {
            "application/json" = {
              "schema" = {
                "$ref" = "#/components/schemas/Error"
              }
            }
          }
          "required" = true
        }

        "x-amazon-apigateway-integration" = {
          "connectionId"   = data.aws_api_gateway_vpc_link.eks_nlb_vpc_links[ns].id
          "httpMethod"     = "ANY"
          "uri"            = "https://${config.nlb_dns_name}/{proxy}"
          "connectionType" = "VPC_LINK"
          "type"           = "http_proxy"

          "requestParameters" = {
            "integration.request.path.proxy" = "method.request.path.proxy"
          }

          "passthroughBehavior" = "when_no_match"
          "cacheNamespace"      = "dd3qbt"
          "timeoutInMillis"      = 29000

          "cacheKeyParameters" = [
            "method.request.path.proxy"
          ]
        }
      }
    }
  }

  api = {
    "openapi" = "3.0.1"

    "info" = {
      "title"   = var.api_gateway_name
      "version" = "1.0.0"
    }

    "paths" = local.api_paths

    "components" = {
      "schemas" = {
        "Error" = {
          "title" = "Error Schema"
          "type"  = "object"

          "properties" = {
            "message" = {
              "type" = "string"
            }
          }
        }
      }
    }

    "x-amazon-apigateway-gateway-responses" = {
      "ACCESS_DENIED" = {
        "responseTemplates" = {
          "application/json" = jsonencode({
            message    = "$context.authorizer.customErrorMessage"
            statusCode = "403"
          })
        }
        "statusCode" = "403"
      }

      "UNAUTHORIZED" = {
        "responseTemplates" = {
          "application/json" = jsonencode({
            message    = "Pass access token to validate authorizer"
            statusCode = "401"
          })
        }
        "statusCode" = "401"
      }
    }

    "security" = [
      {
        "forgerock" = []
      }
    ]
  }

  api_json = jsonencode(local.api)
}