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


data "btp_globalaccount" "this" {}

locals {
  service_name_prefix = lower(replace("${var.project_stage}-${var.project_name}", " ", "-"))

  service_name           = "xsuaa"
  service_plan_name      = "application"
  service_plan_name__api = "apiaccess"
}

# Entitle
resource "btp_subaccount_entitlement" "sap_xsuaa" {
  subaccount_id = var.subaccount_id
  service_name  = local.service_name
  plan_name     = local.service_plan_name
}

resource "btp_subaccount_entitlement" "cf_xsuaa_api" {
  subaccount_id = var.subaccount_id
  service_name  = local.service_name
  plan_name     = local.service_plan_name__api
}

# Service Instance for general Cloud Foundry applications
data "btp_subaccount_service_plan" "sap_xsuaa" {
  subaccount_id = var.subaccount_id
  
  offering_name = local.service_name
  name          = local.service_plan_name
  
  depends_on    = [btp_subaccount_entitlement.sap_xsuaa]
}

# Create service instance
resource "btp_subaccount_service_instance" "sap_xsuaa"{
   subaccount_id  = var.subaccount_id
   
   serviceplan_id = data.btp_subaccount_service_plan.sap_xsuaa.id
   
   name           = "${local.service_name_prefix}-xsuaa"
   
  depends_on = [
    data.btp_subaccount_service_plan.sap_xsuaa
  ]
}

# Cloud Foundry specific Service Instance for XSUAA API Access
data "cloudfoundry_service_plan" "cf_xsuaa_api" {
  service_offering_name = local.service_name
  name                  = local.service_plan_name__api

  depends_on = [ btp_subaccount_entitlement.cf_xsuaa_api ]
}


# Instance creation
resource "cloudfoundry_service_instance" "cf_xsuaa_api" {
  
  name         = local.service_name
  service_plan = data.cloudfoundry_service_plan.cf_xsuaa_api.id
  
  space        = var.cf_space_id

  type         = "managed"
  
  timeouts = {
    create = "15m"
    delete = "15m"
    update = "15m"
  }

  depends_on = [ data.cloudfoundry_service_plan.cf_xsuaa_api ]
}

# Service key creation (for ABAP Development Tools (ADT))
resource "cloudfoundry_service_credential_binding" "abap_trial_service_key" {
  type             = "key"
  name             = "xsuaa_api_key"
  service_instance = cloudfoundry_service_instance.cf_xsuaa_api.id

  depends_on = [ cloudfoundry_service_instance.cf_xsuaa_api ]
}
