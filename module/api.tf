locals {
  paths = [
    for ns, backend in var.api_backends : {
      "/${ns}/{proxy+}" = {
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
            "connectionId" = data.aws_api_gateway_vpc_link.eks_nlb_vpc_links[ns].id

            "httpMethod" = "ANY"

            "uri" = "https://${backend.nlb_dns_name}/{proxy}"

            "requestParameters" = {
              "integration.request.path.proxy" = "method.request.path.proxy"

              "integration.request.header.Authorization" = "context.authorizer.Authorization"

              "integration.request.header.payload" = "context.authorizer.payload"
            }

            "passthroughBehavior" = "when_no_match"

            "connectionType" = "VPC_LINK"

            "cacheNamespace" = "dd3qbt"

            "timeoutInMillis" = 29000

            "cacheKeyParameters" = [
              "method.request.path.proxy"
            ]

            "type" = "http_proxy"
          }
        }
      }
    }
  ]

  paths_merged = merge(local.paths...)

  api = {
    "openapi" = "3.0.1"

    "info" = {
      "title"   = var.api_gateway_name
      "version" = var.api_version
    }

    "paths" = local.paths_merged

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
          "application/json" = "{\"message\": \"$context.authorizer.customErrorMessage\", \"statusCode\": \"403\"}"
        }

        "statusCode" = "403"
      }

      "UNAUTHORIZED" = {
        "responseTemplates" = {
          "application/json" = "{\"message\": \"Pass access token to validate authorizer\", \"statusCode\": \"401\"}"
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

module "service-apigateway" {
  source = "app.terraform.io/lplfinancial-platforms/module-apigateway-authorizer/aws"

  # Confirm the exact deployed version before migration.
  version = "2.0.1"

  name = var.api_gateway_name

  xray_tracing_enabled = true

  body = local.api_json

  vpc_endpoint_ids = var.allowed_external_vpc_endpoint_ids

  # lambda_authorizer_log_level = "DEBUG"
}