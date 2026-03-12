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

  service_name_prefix = lower(replace("${var.project_stage}-${var.project_name}", " ", "-"))

  # Development Tools
  service_name__hana_cloud_tools = "hana-cloud-tools"
  service_plan__hana_cloud_tools = "tools"

  service_name__hana = "hana"
  service_plan__hana = "hdi-shared"

  service_name__hana_cloud = "hana-cloud"
  service_plan__hana_cloud = "hana-free"
  
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!*-"
}

# Entitlements for HANA Cloud Trial
resource "btp_subaccount_entitlement" "hana_cloud_tools" {
  subaccount_id = var.subaccount_id
  
  service_name  = local.service_name__hana_cloud_tools
  plan_name     = local.service_plan__hana_cloud_tools
}

resource "btp_subaccount_entitlement" "hana_hdi_shared" {
  subaccount_id = var.subaccount_id

  service_name  = local.service_name__hana
  plan_name     = local.service_plan__hana
}


resource "btp_subaccount_entitlement" "hana_cloud" {
  subaccount_id = var.subaccount_id

  service_name  = local.service_name__hana
  plan_name     = local.service_plan__hana
}

# Entitlements for HANA Cloud Trial
resource "btp_subaccount_entitlement" "hana_cloud_trial" {
  subaccount_id = var.subaccount_id

  service_name  = "hana-cloud"
  plan_name     = "hana-free"
}


resource "btp_subaccount_subscription" "hana_cloud_tools" {
  subaccount_id = var.subaccount_id
  
  app_name      = local.service_name__hana_cloud_tools
  plan_name     = local.service_plan__hana_cloud_tools

  depends_on    = [btp_subaccount_entitlement.hana_cloud_tools]
}



# Get plan for SAP HANA Cloud
data "btp_subaccount_service_plan" "hana_cloud_trial" {
  subaccount_id = var.subaccount_id
  
  offering_name = "hana-cloud"
  name          = "hana-free"
  
  depends_on    = [btp_subaccount_entitlement.hana_cloud_trial]
}

# Create service instance for SAP HANA Cloud
#      systemPassword           = "Test1234!"
resource "btp_subaccount_service_instance" "hana_cloud"{
   subaccount_id  = var.subaccount_id
   
   serviceplan_id = data.btp_subaccount_service_plan.hana_cloud_trial.id
   
   name           = "${local.service_name_prefix}-hana-db"
   
   parameters = jsonencode({
    data = {
      memory                   = 16
      vcpu                     = 1
      generateSystemPassord    = false
      systemPassword           = "${random_password.password.result}"
      enabledservices = {
        docstore = false
        dpserver = false
        scriptserver = false
      }
      whitelistIPs = ["0.0.0.0/0"]  # Allow all IPs - use with caution in production
    }
  })
  
  timeouts = {
    create = "45m"
    update = "15m"
    delete = "15m"
  }

  depends_on = [
    btp_subaccount_entitlement.hana_cloud_trial,
    data.btp_subaccount_service_plan.hana_cloud_trial,
    btp_subaccount_subscription.hana_cloud_tools
  ]
}


# ------------------------------------------------------------------------------------------------------
# Assign role collection "SAP Business Application Studio"
# ------------------------------------------------------------------------------------------------------
resource "btp_subaccount_role_collection_assignment" "hana_admin" {
  subaccount_id        = var.subaccount_id

  role_collection_name = "SAP HANA Cloud Administrator"
  for_each             = toset(var.admins)
  user_name            = each.value

  depends_on           = [btp_subaccount_subscription.hana_cloud_tools]
}


resource "btp_subaccount_role_collection_assignment" "hana_viewer" {
  subaccount_id        = var.subaccount_id

  role_collection_name = "SAP HANA Cloud Viewer"
  for_each             = toset(var.developers)
  user_name            = each.value

  depends_on           = [btp_subaccount_subscription.hana_cloud_tools]
}

resource "btp_subaccount_role_collection_assignment" "hana_security" {
  subaccount_id        = var.subaccount_id

  role_collection_name = "SAP HANA Cloud Security Administrator"
  for_each             = toset(var.admins)
  user_name            = each.value

  depends_on           = [btp_subaccount_subscription.hana_cloud_tools]
}
