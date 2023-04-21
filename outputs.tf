output "api_id" {
  value = aws_apigatewayv2_api.this.id
}

output "api_execution_arn" {
  value = aws_apigatewayv2_api.this.execution_arn
}
