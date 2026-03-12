

terraform {
  required_providers {
    btp = {
      source = "SAP/btp"
    }
  }
}

resource "random_uuid" "uuid" {}

data "btp_globalaccount" "this" {}

locals {
  service_name_prefix = lower(replace("${var.project_stage}-${var.project_name}", " ", "-"))

  # Enduser Portal
  service_name__sap_launchpad  = "SAPLaunchpad"
  service_plan__sap_launchpad  = "standard"

  # Mobile Services Portal
  service_name__sap_mobile_services  = "mobile-services"
  service_plan__sap_mobile_services  = "lite"
}

# ------------------------------------------------------------------------------------------------------
# Setup SAPLaunchpad (SAP Build Work Zone, standard edition)
# ------------------------------------------------------------------------------------------------------
# Entitle
resource "btp_subaccount_entitlement" "sap_launchpad" {
  subaccount_id = var.subaccount_id
  service_name  = local.service_name__sap_launchpad
  plan_name     = local.service_plan__sap_launchpad
  #amount        = 1
}

# Subscribe
resource "btp_subaccount_subscription" "sap_launchpad" {
  subaccount_id = var.subaccount_id
  app_name      = local.service_name__sap_launchpad
  plan_name     = local.service_plan__sap_launchpad
  depends_on    = [btp_subaccount_entitlement.sap_launchpad]
}

data "btp_subaccount_subscription" "sap_launchpad_data" {
  subaccount_id = var.subaccount_id
  app_name      = "${local.service_name__sap_launchpad}SMS"
  plan_name     = local.service_plan__sap_launchpad
  depends_on    = [btp_subaccount_subscription.sap_launchpad]
}

# ------------------------------------------------------------------------------------------------------
# Setup Mobile Services for (SAP Build Work Zone, standard edition)
# ------------------------------------------------------------------------------------------------------
# Entitle
resource "btp_subaccount_entitlement" "sap_mobile_services" {
  subaccount_id = var.subaccount_id
  service_name  = local.service_name__sap_mobile_services
  plan_name     = local.service_plan__sap_mobile_services
  amount        = 1
}


/*data "btp_subaccount_subscription" "sap_mobile_services" {
  subaccount_id = var.subaccount_id
  app_name      = "${local.service_name__sap_mobile_services}SMS"
  plan_name     = local.service_plan__sap_launchpad
  depends_on    = [btp_subaccount_subscription.sap_launchpad]
}*/
# ------------------------------------------------------------------------------------------------------
# Assign role collection "Launchpad_Admin"
# ------------------------------------------------------------------------------------------------------
# Assign users
resource "btp_subaccount_role_collection_assignment" "launchpad_admin" {
  for_each             = toset("${var.launchpad_admins}")
  subaccount_id        = var.subaccount_id
  role_collection_name = "Launchpad_Admin"
  user_name            = each.value
  origin               = var.custom_idp_origin
  depends_on           = [btp_subaccount_subscription.sap_launchpad]
}

resource "btp_subaccount_role_collection_assignment" "launchpad_theme_admin" {
  for_each             = toset("${var.launchpad_admins}")
  subaccount_id        = var.subaccount_id
  role_collection_name = "Launchpad_Advanced_Theming"
  user_name            = each.value
  origin               = var.custom_idp_origin
  depends_on           = [btp_subaccount_subscription.sap_launchpad]
}
/*
# Optional to assign later
resource "btp_subaccount_role_collection_assignment" "launchpad_admin_support" {
  for_each             = toset("${var.launchpad_admins}")
  subaccount_id        = var.subaccount_id
  role_collection_name = "Launchpad_Admin_Read_Only"
  user_name            = each.value
  origin               = var.custom_idp_origin
  depends_on           = [btp_subaccount_subscription.sap_launchpad]
}

resource "btp_subaccount_role_collection_assignment" "launchpad_external_user" {
  for_each             = toset("${var.launchpad_admins}")
  subaccount_id        = var.subaccount_id
  role_collection_name = "Launchpad_External_User"
  user_name            = each.value
  origin               = var.custom_idp_origin
  depends_on           = [btp_subaccount_subscription.sap_launchpad]
}*/
# ------------------------------------------------------------------------------------------------------
# Assign role collection "Mobile Services Admin"
# ------------------------------------------------------------------------------------------------------
locals {
  role_collection_mobile_service_admin = "mobile_service_admin"
}
resource "btp_subaccount_role_collection" "mobile_services_admin" {
  subaccount_id = var.subaccount_id
  name          = local.role_collection_mobile_service_admin
  description   = "Admin role collection for Mobile Services (.e.g. for SAP Build Work Zone, standard edition)"

  roles = [
    {
      name                 = "MobileAdmin"
      role_template_app_id = "launchpad-dt-approuter!t1483"
      role_template_name   = "MobileAdmin"
    },
    {
      name                 = "MobileAdminReadOnly"
      role_template_app_id = "launchpad-dt-approuter!t1483"
      role_template_name   = "MobileAdminReadOnly"
    }
  ]
  depends_on = [ btp_subaccount_subscription.sap_launchpad ]
}

resource "btp_subaccount_role_collection_assignment" "mobile_services_admin" {
  for_each             = toset("${var.launchpad_admins}")
  subaccount_id        = var.subaccount_id
  role_collection_name = local.role_collection_mobile_service_admin
  user_name            = each.value
  origin               = var.custom_idp_origin
  depends_on           = [btp_subaccount_role_collection.mobile_services_admin]
}