terraform {
  required_providers {
    keycloak = {
      source = "mrparkers/keycloak"
      version = "2.3.0"
    }
  }
}

########## Variables ##########
variable "realm_name" {
    description = "Name of the realm to be configured"
    type        = string
}

variable "keycloak_URL" {
    description = "URL for the Keycloak instance"
    type        = string
}

variable "keycloak_user" {
    description = "username of the keycloak administration user"
    type        = string
    sensitive   =  true
}

variable "keycloak_pass" {
    description = "password for keycloak administration user"
    type        = string
    sensitive   = true
}

variable "ldap_user" {
    description = "username for the LDAP connection user"
    type        = string
    sensitive   = true
}

variable "ldap_pass" {
    description = "password for the LDAP connection user"
    type        = string
    sensitive   = true
}

variable "ldap_URL" {
    description = "url for LDAP connection"
    type        = string
}

variable "ldap_UsersDN" {
    description = "DN for users OU"
    type        = string
}

########## Providers ##########

provider "keycloak" {
    client_id     = "admin-cli"
    username      = var.keycloak_user
    password      = var.keycloak_pass
    url           = var.keycloak_URL
}

########## resources ##########

resource "keycloak_realm" "realm" {
  realm             = var.realm_name
  enabled           = true
}

#Set up AD connection
resource "keycloak_ldap_user_federation" "AD_Connection" {
  name     = "ldap"
  realm_id = keycloak_realm.realm.id
  enabled  = true

  username_ldap_attribute = "cn"
  rdn_ldap_attribute      = "cn"
  uuid_ldap_attribute     = "entryDN"
  user_object_classes     = [
    "simpleSecurityObject",
    "organizationalRole"
  ]
  connection_url          = var.ldap_URL
  users_dn                = var.ldap_UsersDN
  bind_dn                 = var.ldap_user
  bind_credential         = var.ldap_pass
}

# Set up a local user
resource "keycloak_user" "user_with_initial_password" {
  realm_id   = keycloak_realm.realm.id
  username   = "alice"
  enabled    = true

  email      = "alice@domain.com"
  first_name = "Alice"
  last_name  = "Aliceberg"

  attributes = {
    foo = "bar"
  }

  initial_password {
    value     = "some password"
    temporary = true
  }
}
