variable "hosted_zone" {
  type        = string
  description = "(Required) describe your variable"
}

variable "custom_dns" {
  type        = string
  description = "(Required) describe your variable"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags applied to all resources."
  default     = {}
}
