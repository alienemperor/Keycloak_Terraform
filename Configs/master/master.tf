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

variable "ldap_connectionName" {
    description = "Name for the LDAP connection"
    type       = string
}

variable "ldap_user" {
    description = "Username for the LDAP connection user"
    type        = string
    sensitive   = true
}

variable "ldap_pass" {
    description = "Password for the LDAP connection user"
    type        = string
    sensitive   = true
}

variable "ldap_URL" {
    description = "URL for LDAP connection"
    type        = string
}

variable "ldap_usersDN" {
    description = "DN for users OU"
    type        = string
}

variable "ldap_groupConnectionName" {
    description = "Name of the group LDAP mapper"
    type        = string
}

variable "ldap_groupsDN" {
    description = "DN for groups OU"
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
  name     = var.ldap_connectionName
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
  users_dn                = var.ldap_usersDN
  bind_dn                 = var.ldap_user
  bind_credential         = var.ldap_pass
}

#Sync Groups from AD
resource "keycloak_ldap_group_mapper" "Ad_group_mapper" {
    realm_id                 = keycloak_realm.realm.id
    ldap_user_federation_id  = keycloak_ldap_user_federation.AD_Connection.id
    name                     = var.ldap_groupConnectionName

    ldap_groups_dn                 = var.ldap_groupsDN
    group_name_ldap_attribute      = "cn"
    group_object_classes           = [
        "group"
    ]
    preserve_group_inheritance     = "false"
    membership_attribute_type      = "DN"
    membership_ldap_attribute      = "member"
    membership_user_ldap_attribute = "cn"
    memberof_ldap_attribute        = "memberOf"
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
