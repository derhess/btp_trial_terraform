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


locals {
  # Development Tools - AppGyver - Low Code/No Code
  service_name__build_apps = "sap-build-apps"
  service_plan__build_apps = "free"
}

# ------------------------------------------------------------------------------------------------------
# Setup Variables
# ------------------------------------------------------------------------------------------------------

# Entitle
resource "btp_subaccount_entitlement" "build_apps" {
  subaccount_id = var.subaccount_id

  service_name  = local.service_name__build_apps
  plan_name     = local.service_plan__build_apps

  amount = 1
}


# Subscribe
resource "btp_subaccount_subscription" "build_apps" {

  subaccount_id = var.subaccount_id
  app_name      = local.service_name__build_apps
  plan_name     = btp_subaccount_entitlement.build_apps.plan_name

  depends_on = [ btp_subaccount_entitlement.build_apps ]
}

# ------------------------------------------------------------------------------------------------------
# Assign role collection "SAP Business Application Studio"
# ------------------------------------------------------------------------------------------------------
# Assign users
# ------------------------------------------------------------------------------------------------------
# Assign role collection "Mobile Services Admin"
# ------------------------------------------------------------------------------------------------------
locals {
  role_collection_build_apps_admin = "build_apps_admin"
  role_collection_build_apps_developer = "build_apps_developer"
}

#Admin role collection for SAP Build Apps
resource "btp_subaccount_role_collection" "build_apps_admin" {
  subaccount_id = var.subaccount_id
  name          = local.role_collection_build_apps_admin
  description   = "Admin role collection for SAP Build Apps"

  roles = [
    {
      name                 = "BuildAppsAdmin"
      role_template_app_id = "appgyver-xsuaa!b107153"
      role_template_name   = "BuildAppsAdmin"
    }
  ]
  depends_on = [ btp_subaccount_subscription.build_apps ]
}

resource "btp_subaccount_role_collection_assignment" "build_apps_admin" {
  for_each             = toset("${var.admins}")
  subaccount_id        = var.subaccount_id
  role_collection_name = local.role_collection_build_apps_admin
  user_name            = each.value
  #origin               = var.custom_idp_origin
  depends_on           = [btp_subaccount_role_collection.build_apps_admin]
}

#Developer role collection for SAP Build Apps
resource "btp_subaccount_role_collection" "build_apps_developer" {
  subaccount_id = var.subaccount_id
  name          = local.role_collection_build_apps_developer
  description   = "Developer role collection for SAP Build Apps"

  roles = [
    {
      name                 = "BuildAppsDeveloper"
      role_template_app_id = "appgyver-xsuaa!b107153"
      role_template_name   = "BuildAppsDeveloper"
    }
  ]
  depends_on = [ btp_subaccount_subscription.build_apps ]
}

resource "btp_subaccount_role_collection_assignment" "build_apps_developer" {
  for_each             = toset("${var.developers}")
  subaccount_id        = var.subaccount_id
  role_collection_name = local.role_collection_build_apps_developer
  user_name            = each.value
#  origin               = var.custom_idp_origin
  depends_on           = [btp_subaccount_role_collection.build_apps_developer]
}
