variable "kc_admin_url" {
  type        = string
  nullable    = false
  description = "The URL of the Keycloak admin server. See the HELM deployment for the correct URL."
}

variable "kc_admin_client_id" {
  type        = string
  nullable    = false
  default     = "admin-cli"
  description = "The client ID of the Keycloak admin server. Example: admin-cli"
}

variable "kc_admin_username" {
  type        = string
  nullable    = false
  description = "The username of the Keycloak admin server. See the HELM deployment for the correct username."
}

variable "kc_admin_password" {
  type        = string
  nullable    = false
  description = "The password of the Keycloak admin server. See the HELM deployment for the correct password."
}
