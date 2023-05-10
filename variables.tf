#-----------------------------------------------------------
# Common
#-----------------------------------------------------------
variable "name" {
  type        = string
  description = "(Required) This name will be used in all resources."
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags applied to all resources."
  default     = {}
}

#-----------------------------------------------------------
# API Gateway
#-----------------------------------------------------------
variable "apigateway_version" {
  type        = string
  description = "(Optional) Type of API Gateway to create. Use v1 for REST APIs and v2 for HTTP/WEBSOCKET APIs."
  default     = "v2"
}

variable "protocol_type" {
  type        = string
  description = "(Optional) API protocol. Only for API GAteway v2. Valid values: HTTP, WEBSOCKET."
  default     = "HTTP"
}

variable "description" {
  type        = string
  description = "(Optional) Description of the API. Must be less than or equal to 1024 characters in length."
  default     = ""
}

variable "disable_execute_api_endpoint" {
  type        = bool
  description = "(Optional) Whether clients can invoke the API by using the default execute-api endpoint. By default, clients can invoke the API with the default {api_id}.execute-api.{region}.amazonaws.com endpoint. To require that clients use a custom domain name to invoke the API, disable the default endpoint."
  default     = false
}

#-----------------------------------------------------------
# Route 53
#-----------------------------------------------------------
variable "custom_domain_enabled" {
  type        = bool
  description = "(Optional) Enable custom DNS resources."
  default     = false
}

variable "hosted_zone" {
  type        = string
  description = "(Optional) Hosted Zone name of the desired Hosted Zone."
  default     = ""
}

variable "custom_domain_name" {
  type        = string
  description = "(Optional) Domain name. Must be between 1 and 512 characters in length."
  default     = ""
}
