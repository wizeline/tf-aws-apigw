#-----------------------------------------------------------
# API Gateway v1
#-----------------------------------------------------------
resource "aws_api_gateway_rest_api" "this" {
  count = var.apigateway_version == "v1" ? 1 : 0

  name        = var.name
  description = var.description

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

resource "aws_api_gateway_domain_name" "this" {
  count = var.custom_domain_enabled && var.apigateway_version == "v1" ? 1 : 0

  domain_name              = var.custom_domain_name
  regional_certificate_arn = module.certificate[count.index].certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

#-----------------------------------------------------------
# API Gateway v2
#-----------------------------------------------------------
resource "aws_apigatewayv2_api" "this" {
  count = var.apigateway_version == "v2" ? 1 : 0

  name          = var.name
  protocol_type = var.protocol_type
  description   = var.description

  tags = var.tags
}

resource "aws_apigatewayv2_stage" "this" {
  count = var.apigateway_version == "v2" ? 1 : 0

  name        = var.name
  api_id      = aws_apigatewayv2_api.this[count.index].id
  auto_deploy = true

  tags = var.tags
}

resource "aws_apigatewayv2_domain_name" "this" {
  count = var.custom_domain_enabled && var.apigateway_version == "v2" ? 1 : 0

  domain_name = var.custom_domain_name

  domain_name_configuration {
    certificate_arn = module.certificate[count.index].certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = var.tags

  depends_on = [module.certificate]
}

resource "aws_apigatewayv2_api_mapping" "this" {
  count = var.custom_domain_enabled && var.apigateway_version == "v2" ? 1 : 0

  api_id      = aws_apigatewayv2_api.this[count.index].id
  domain_name = aws_apigatewayv2_domain_name.this[count.index].id
  stage       = aws_apigatewayv2_stage.this[count.index].id
}

#-----------------------------------------------------------
# Certificate
#-----------------------------------------------------------
module "certificate" {
  count = var.custom_domain_enabled ? 1 : 0

  source = "./modules/certificate"

  hosted_zone = var.hosted_zone
  custom_dns  = var.custom_domain_name

  tags = var.tags
}

#-----------------------------------------------------------
# Route53
#-----------------------------------------------------------
resource "aws_route53_record" "this" {
  count = var.custom_domain_enabled ? 1 : 0

  name    = var.custom_domain_name
  type    = "A"
  zone_id = module.certificate[count.index].hosted_zone_id

  alias {
    name                   = var.apigateway_version == "v1" ? aws_api_gateway_domain_name.this[count.index].regional_domain_name : aws_apigatewayv2_domain_name.this[count.index].domain_name_configuration[0].target_domain_name
    zone_id                = var.apigateway_version == "v1" ? aws_api_gateway_domain_name.this[count.index].regional_zone_id : aws_apigatewayv2_domain_name.this[count.index].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }

  depends_on = [module.certificate]
}
