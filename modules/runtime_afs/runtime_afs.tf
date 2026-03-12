terraform {
  required_providers {
    btp = {
      source = "SAP/btp"
    }
  }
}


# ------------------------------------------------------------------------------------------------------
# Setup Variables
# ------------------------------------------------------------------------------------------------------

data "btp_whoami" "me" {}

locals {

  # Runtime
  service_name__application_frontend      = "application-frontend"
  service_name__application_frontend_plan = "trial"

  origin_key = data.btp_whoami.me.issuer != var.custom_idp ? "sap.default" : var.custom_idp
}


# ------------------------------------------------------------------------------------------------------
# Setup Application Frontend Service Trial
# ------------------------------------------------------------------------------------------------------
# Entitle
resource "btp_subaccount_entitlement" "app_frontend" {
  subaccount_id = var.subaccount_id
  service_name  = local.service_name__application_frontend
  plan_name     = local.service_name__application_frontend_plan
}

# Instance creation
resource "btp_subaccount_subscription" "app_frontend" {

  subaccount_id = var.subaccount_id
  
  app_name      = local.service_name__application_frontend
  plan_name     = local.service_name__application_frontend_plan
  
  depends_on = [btp_subaccount_entitlement.app_frontend]
}


# ------------------------------------------------------------------------------------------------------
# Assign role collection "Application Frontend Service Developer"
# ------------------------------------------------------------------------------------------------------
locals {
  role_collection_application_frontend_developer = "application-frontend-developer"
}
resource "btp_subaccount_role_collection" "application_frontend_developer" {
  subaccount_id = var.subaccount_id
  name          = local.role_collection_application_frontend_developer
  description   = "Developer role collection for Application Frontend Service"

  roles = [
    {
      name                 = "Application_Frontend_Developer"
      role_template_app_id = "us10-appfront!b415322"
      role_template_name   = "Application_Frontend_Developer"
    },
    {
      name                 = "Application_Frontend_Viewer"
      role_template_app_id = "us10-appfront!b415322"
      role_template_name   = "Application_Frontend_Viewer"
    }
  ]
  depends_on = [ btp_subaccount_subscription.app_frontend ]
}

resource "btp_subaccount_role_collection_assignment" "application_frontend_developer" {
  for_each             = toset("${var.developers}")
  subaccount_id        = var.subaccount_id
  role_collection_name = local.role_collection_application_frontend_developer
  user_name            = each.value

  depends_on           = [btp_subaccount_role_collection.application_frontend_developer]
}