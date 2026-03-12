terraform {
  required_providers {
    cloudfoundry = {
      source  = "cloudfoundry/cloudfoundry"
    }
    btp = {
      source = "SAP/btp"
    }
  }
}


# ------------------------------------------------------------------------------------------------------
# Setup Variables
# ------------------------------------------------------------------------------------------------------

locals {
  # Development Tools
  service_name__sap_build_code = "build-code"
  plan_name__sap_build_code = "free"

}

# ------------------------------------------------------------------------------------------------------
# Setup build-code (SAP Build Code)
# ------------------------------------------------------------------------------------------------------

# Entitle
resource "btp_subaccount_entitlement" "build_code" {
  subaccount_id = var.subaccount_id
  service_name  = local.service_name__sap_build_code
  plan_name     = local.plan_name__sap_build_code 
}


# Subscribe
resource "btp_subaccount_subscription" "build_code" {
  subaccount_id = var.subaccount_id

  app_name      = local.service_name__sap_build_code
  plan_name     = btp_subaccount_entitlement.build_code.plan_name

  depends_on = [ btp_subaccount_entitlement.build_code ]
}



# ------------------------------------------------------------------------------------------------------
# Assign role collection "Build Code"
# ------------------------------------------------------------------------------------------------------
# Admin users
resource "btp_subaccount_role_collection_assignment" "build_code_admin" {
  for_each             = toset("${var.admins}")
  subaccount_id        = var.subaccount_id
  role_collection_name = "Business_Application_Studio_Administrator"
  user_name            = each.value
  depends_on           = [btp_subaccount_subscription.build_code]
}


resource "btp_subaccount_role_collection_assignment" "build_code_lobby_admin" {
  for_each             = toset("${var.admins}")
  subaccount_id        = var.subaccount_id
  #origin               = btp_subaccount_trust_configuration.fully_customized.origin
  role_collection_name = "Build Code - Lobby Admin"
  user_name            = each.value
  depends_on           = [btp_subaccount_subscription.build_code]
}

# Assign Developer roles
resource "btp_subaccount_role_collection_assignment" "build_code_developer" { 
  for_each             = toset("${var.developers}")
  subaccount_id        = var.subaccount_id
  role_collection_name = "Business_Application_Studio_Developer"
  user_name            = each.value
  depends_on           = [btp_subaccount_subscription.build_code]
}


resource "btp_subaccount_role_collection_assignment" "build_code_lobby_developer" {
  for_each             = toset("${var.developers}")
  subaccount_id        = var.subaccount_id
  #origin               = btp_subaccount_trust_configuration.fully_customized.origin
  role_collection_name = "Build Code - Lobby Developer"
  user_name            = each.value
  depends_on           = [btp_subaccount_subscription.build_code]
}
