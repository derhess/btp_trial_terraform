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

  # Runtime
  service_name__abap      = "abap-trial"
  service_name__abap_plan = "shared"

  origin_key = data.btp_whoami.me.issuer != var.custom_idp ? "sap.default" : var.custom_idp
}


# ------------------------------------------------------------------------------------------------------
# Setup abap-trial (ABAP environment) - based on Mission 3248 (trial) und depends on Cloud Foundry
# ------------------------------------------------------------------------------------------------------

# Entitle
resource "btp_subaccount_entitlement" "abap_trial" {
  subaccount_id = var.subaccount_id
  service_name  = local.service_name__abap
  plan_name     = local.service_name__abap_plan
  amount        = 1

}

data "cloudfoundry_service_plan" "abap_trial" {
  service_offering_name = local.service_name__abap
  name                  = local.service_name__abap_plan

  depends_on = [ btp_subaccount_entitlement.abap_trial ]
}


# Instance creation
resource "cloudfoundry_service_instance" "abap_trial" {
  
  name         = local.service_name__abap
  service_plan = data.cloudfoundry_service_plan.abap_trial.id
  
  space        = var.cf_space_id

  type         = "managed"
  parameters = jsonencode({
    email = "${var.abap_admin_email}"
  })
  timeouts = {
    create = "30m"
    delete = "30m"
    update = "30m"
  }

  depends_on = [btp_subaccount_entitlement.abap_trial, data.cloudfoundry_service_plan.abap_trial]
}

# Service key creation (for ABAP Development Tools (ADT))
resource "cloudfoundry_service_credential_binding" "abap_trial_service_key" {
  type             = "key"
  name             = "abap_trial_adt_key"
  service_instance = cloudfoundry_service_instance.abap_trial.id

  depends_on = [ cloudfoundry_service_instance.abap_trial ]
}

# ------------------------------------------------------------------------------------------------------
#  USERS AND ROLES
# ------------------------------------------------------------------------------------------------------
#
# Get all roles in the subaccount

data "btp_subaccount_roles" "all" {
  subaccount_id = var.subaccount_id
  #depends_on    = [btp_subaccount_subscription.sap_build_apps]
}

