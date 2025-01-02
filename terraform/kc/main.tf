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
  reset_password_allowed         = true
  display_name                   = "Aga.rso"
  registration_email_as_username = true
  login_with_email_allowed       = true
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
}

resource "keycloak_openid_client" "fe-client" {
  access_type           = "PUBLIC"
  client_id             = "fe-client"
  realm_id              = keycloak_realm.agarso-realm.id
  enabled               = true
  description           = "Used by the frontend to login over the browser"
  valid_redirect_uris = ["*"]
  web_origins = ["*"]
  standard_flow_enabled = true
}

locals {
  users = [
    {
      username = "jan"
      password = "jan12345678"
    },
    {
      username = "matej"
      password = "matej12345678"
    },
    {
      username = "ziga"
      password = "ziga12345678"
    },
    {
      username = "guest"
      password = "guest12345678"
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
  first_name     = each.value.username
  last_name      = "User"
}
