#-----------------------------------------------------------
# API Gateway
#-----------------------------------------------------------
resource "aws_apigatewayv2_api" "this" {
  name          = var.name
  protocol_type = var.protocol_type

  tags = var.tags
}

resource "aws_apigatewayv2_stage" "this" {
  name        = var.name
  api_id      = aws_apigatewayv2_api.this.id
  auto_deploy = true

  tags = var.tags
}

resource "aws_apigatewayv2_domain_name" "this" {
  count = var.custom_dns_enabled ? 1 : 0

  domain_name = var.custom_dns

  domain_name_configuration {
    certificate_arn = module.certificate[count.index].certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = var.tags

  depends_on = [module.certificate]
}

resource "aws_apigatewayv2_api_mapping" "this" {
  count = var.custom_dns_enabled ? 1 : 0

  api_id      = aws_apigatewayv2_api.this.id
  domain_name = aws_apigatewayv2_domain_name.this[count.index].id
  stage       = aws_apigatewayv2_stage.this.id
}

#-----------------------------------------------------------
# Certificate
#-----------------------------------------------------------
module "certificate" {
  count = var.custom_dns_enabled ? 1 : 0

  source = "./modules/certificate"

  hosted_zone = var.hosted_zone
  custom_dns  = var.custom_dns

  tags = var.tags
}

#-----------------------------------------------------------
# Route53
#-----------------------------------------------------------
resource "aws_route53_record" "this" {
  count = var.custom_dns_enabled ? 1 : 0

  name    = aws_apigatewayv2_domain_name.this[count.index].domain_name
  type    = "A"
  zone_id = module.certificate[count.index].hosted_zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.this[count.index].domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.this[count.index].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }

  depends_on = [module.certificate]
}
