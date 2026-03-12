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

  subaccount_name      = "${var.project_stage} ${var.project_name}"
  subaccount_subdomain = join("-", [lower(replace("${var.project_stage}-${var.project_name}", " ", "-")), random_uuid.uuid.result])
  beta_enabled         = var.project_stage == "PROD" ? false : true
  subaccount_cf_org    = local.subaccount_subdomain
}

# ------------------------------------------------------------------------------------------------------
# Creation of subaccount
# ------------------------------------------------------------------------------------------------------
resource "btp_subaccount" "project_subaccount" {
  name         = local.subaccount_name
  subdomain    = local.subaccount_subdomain
  region       = var.region
  beta_enabled = local.beta_enabled
  labels = {
    "stage"      = [var.project_stage]
    "costcenter" = [var.project_costcenter]
  }
}

data "btp_subaccount_environments" "all" {
  subaccount_id = btp_subaccount.project_subaccount.id
}


# ------------------------------------------------------------------------------------------------------
# Assign role collection "Subaccount Administrator"
# ------------------------------------------------------------------------------------------------------

resource "btp_subaccount_role_collection_assignment" "emergency_adminitrators" {
  for_each             = toset(var.subaccount_emergency_admins)
  subaccount_id        = btp_subaccount.project_subaccount.id
  role_collection_name = "Subaccount Administrator"
  user_name            = each.value
  depends_on           = [btp_subaccount.project_subaccount]
}

resource "btp_subaccount_role_collection_assignment" "subaccount_admin" {
  for_each             = toset("${var.subaccount_admins}")
  subaccount_id        = btp_subaccount.project_subaccount.id
  role_collection_name = "Subaccount Administrator"
  user_name            = each.value
  depends_on           = [btp_subaccount.project_subaccount]
}

resource "btp_subaccount_role_collection_assignment" "subaccount-viewer" {
  for_each             = toset("${var.subaccount_developers}")
  subaccount_id        = btp_subaccount.project_subaccount.id
  role_collection_name = "Subaccount Viewer"
  user_name            = each.value
  depends_on           = [btp_subaccount.project_subaccount]
}

# Connectivity and Destination Admin Roles
resource "btp_subaccount_role_collection_assignment" "cloud_connector_admin" {
  for_each             = toset("${var.subaccount_admins}")
  subaccount_id        = btp_subaccount.project_subaccount.id
  role_collection_name = "Cloud Connector Administrator"
  user_name            = each.value
  depends_on           = [btp_subaccount.project_subaccount]
}

resource "btp_subaccount_role_collection_assignment" "connectivity_admin" {
  for_each             = toset("${var.subaccount_admins}")
  subaccount_id        = btp_subaccount.project_subaccount.id
  role_collection_name = "Connectivity and Destination Administrator"
  user_name            = each.value
  depends_on           = [btp_subaccount.project_subaccount]
}

resource "btp_subaccount_role_collection_assignment" "destination_admin" {
  for_each             = toset("${var.subaccount_admins}")
  subaccount_id        = btp_subaccount.project_subaccount.id
  role_collection_name = "Destination Administrator"
  user_name            = each.value
  depends_on           = [btp_subaccount.project_subaccount]
}

resource "btp_subaccount_role_collection_assignment" "destination_fragment_admin" {
  for_each             = toset("${var.subaccount_admins}")
  subaccount_id        = btp_subaccount.project_subaccount.id
  role_collection_name = "Destination Fragment Administrator"
  user_name            = each.value
  depends_on           = [btp_subaccount.project_subaccount]
}

