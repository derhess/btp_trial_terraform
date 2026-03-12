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
  service_name__postresgl = "postgresql-db"
  service_plan__postresgl = "trial"
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!*-"
}

# Entitlements for PostgreSQL Trial
resource "btp_subaccount_entitlement" "postgresql" {
  subaccount_id = var.subaccount_id
  
  service_name  = local.service_name__postresgl
  plan_name     = local.service_plan__postresgl

  amount        = 1
}

# Get plan for PostgreSQL Trial
data "btp_subaccount_service_plan" "postgresql" {
  subaccount_id = var.subaccount_id
  
  offering_name = local.service_name__postresgl
  name          = local.service_plan__postresgl
  
  depends_on    = [btp_subaccount_entitlement.postgresql]
}

# Create service instance for PostgreSQL Trial
resource "btp_subaccount_service_instance" "postgresql"{
   subaccount_id  = var.subaccount_id
   
   serviceplan_id = data.btp_subaccount_service_plan.postgresql.id
   
   name           = "${local.service_name_prefix}-postgresql-db"
   
   
  
  timeouts = {
    create = "45m"
    update = "15m"
    delete = "15m"
  }

  depends_on = [
    btp_subaccount_entitlement.postgresql,
    data.btp_subaccount_service_plan.postgresql
  ]
}


# ------------------------------------------------------------------------------------------------------
# Assign role collection "SAP Business Application Studio"
# ------------------------------------------------------------------------------------------------------
/*
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
*/
