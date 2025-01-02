provider "keycloak" {
  client_id = var.kc_admin_client_id
  username  = var.kc_admin_username
  password  = var.kc_admin_password
  url       = var.kc_admin_url
}


resource "keycloak_realm" "agarso-realm" {
  realm                          = "aga.rso"
  enabled                        = true
  remember_me                    = true
  registration_allowed           = true
  reset_password_allowed         = false
  display_name                   = "Aga.rso"
  registration_email_as_username = false
  login_with_email_allowed       = false
  verify_email                   = false

  security_defenses {
    brute_force_detection {
      max_login_failures     = 8
      wait_increment_seconds = 60
    }
  }

}


resource "keycloak_openid_client" "external-client" {
  realm_id              = keycloak_realm.agarso-realm.id
  client_id             = "external-client"
  access_type           = "CONFIDENTIAL"
  enabled               = true
  description           = "Used by the auth/users service"
  valid_redirect_uris = ["*"]
  standard_flow_enabled = true
  implicit_flow_enabled = true
}

resource "keycloak_openid_client" "fe-client" {
  access_type           = "PUBLIC"
  client_id             = "fe-client"
  realm_id              = keycloak_realm.agarso-realm.id
  enabled               = true
  description           = "Used by the frontend to login over the browser"
  valid_redirect_uris = ["*"]
  web_origins = ["*"]
  implicit_flow_enabled = true
  standard_flow_enabled = true
}

locals {
  users = [
    {
      username   = "jan"
      first_name = "Jan"
      last_name  = "RSO"
      password   = "12345678"
    },
    {
      username   = "matej"
      first_name = "Matej"
      last_name  = "RSO"
      password   = "12345678"
    },
    {
      username   = "ziga"
      first_name = "Ziga"
      last_name  = "RSO"
      password   = "12345678"
    },
    {
      username   = "guest"
      first_name = "Guest"
      last_name  = "RSO"
      password   = "12345678"
    }
  ]
}

resource "keycloak_user" "users" {
  for_each       = {for user in local.users : user.username => user}
  email_verified = true
  realm_id       = keycloak_realm.agarso-realm.id
  username       = each.value.username
  enabled        = true
  email          = "${each.value.username}@aga.rso"
  first_name     = each.value.first_name
  last_name      = each.value.last_name

  initial_password {
    value     = each.value.password
    temporary = false
  }
}


resource "keycloak_oidc_identity_provider" "github" {
  alias         = "github"
  client_id     = var.gh_client_id
  client_secret = var.gh_client_secret
  realm         = keycloak_realm.agarso-realm.realm

  provider_id = "github"

  display_name = "GitHub"

  enabled = true

  authorization_url = "https://github.com/login/oauth/authorize"
  token_url         = "https://github.com/login/oauth/access_token"
  user_info_url     = "https://api.github.com/user"
  default_scopes    = "user:email"
}
