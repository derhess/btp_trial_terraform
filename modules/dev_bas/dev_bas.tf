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
resource "random_uuid" "uuid" {}

data "btp_globalaccount" "this" {}

data "btp_whoami" "me" {}

locals {
  # Development Tools
  service_name__sap_app_studio = "sapappstudiotrial"
  
}


# Entitle
resource "btp_subaccount_entitlement" "bas" {
  subaccount_id = var.subaccount_id
  service_name  = local.service_name__sap_app_studio
  plan_name     = "trial"
}


# Subscribe
resource "btp_subaccount_subscription" "bas" {

  subaccount_id = var.subaccount_id
  app_name      = local.service_name__sap_app_studio
  plan_name     = btp_subaccount_entitlement.bas.plan_name

  depends_on = [ btp_subaccount_entitlement.bas ]
}

# ------------------------------------------------------------------------------------------------------
# Assign role collection "SAP Business Application Studio"
# ------------------------------------------------------------------------------------------------------
# Assign users
resource "btp_subaccount_role_collection_assignment" "bas_admins" {
  for_each             = toset("${var.bas_admins}")
  subaccount_id        = var.subaccount_id
  role_collection_name = "Business_Application_Studio_Administrator"
  user_name            = each.value
  #origin               = btp_subaccount_trust_configuration.fully_customized.origin
  depends_on           = [btp_subaccount_subscription.bas]
}

resource "btp_subaccount_role_collection_assignment" "bas_developers" {
  for_each             = toset("${var.bas_developers}")
  subaccount_id        = var.subaccount_id
  role_collection_name = "Business_Application_Studio_Developer"
  user_name            = each.value
  #origin               = btp_subaccount_trust_configuration.fully_customized.origin
  depends_on           = [btp_subaccount_subscription.bas]
}


