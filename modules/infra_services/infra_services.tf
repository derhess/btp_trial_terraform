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
  service_name_prefix = lower(replace("${var.project_stage}-${var.project_name}", " ", "-"))
  
  service_name__alert_notification      = "alert-notification"
  service_plan__alert_notification      = "standard"

  service_name__auto_pilot              = "automationpilot"
  service_plan__auto_pilot              = "free"

  # TODO: add Cloud Transport Manager

  # TODO: add Audit Log Service - Roles

}


# ------------------------------------------------------------------------------------------------------
# Setup Services
# ------------------------------------------------------------------------------------------------------

## Alert Notification Service - Standard Plan ==> TODO: Move Service to INFRA Module

resource "btp_subaccount_entitlement" "alert_notification_service_standard" {
  subaccount_id = var.subaccount_id

  service_name  = local.service_name__alert_notification
  plan_name     = local.service_plan__alert_notification
}

data "btp_subaccount_service_plan" "alert_notification_service_standard" {
  subaccount_id = var.subaccount_id
  
  name          = local.service_plan__alert_notification
  offering_name = local.service_name__alert_notification
  
  depends_on    = [btp_subaccount_entitlement.alert_notification_service_standard]
}

resource "btp_subaccount_service_instance" "alert_notification_service_standard" {
  subaccount_id  = var.subaccount_id
  
  serviceplan_id = data.btp_subaccount_service_plan.alert_notification_service_standard.id
  name           = "${local.service_name_prefix}-${local.service_name__alert_notification}"

  depends_on = [ data.btp_subaccount_service_plan.alert_notification_service_standard ]
}

# Assign users
resource "btp_subaccount_role_collection_assignment" "alert_notification_admins" {
  subaccount_id        = var.subaccount_id
  
  for_each             = toset("${var.admins}")
  role_collection_name = "Business_Notifications_Admin"
  user_name            = each.value
  #origin               = btp_subaccount_trust_configuration.fully_customized.origin
  
  depends_on           = [ btp_subaccount_service_instance.alert_notification_service_standard ] 
}

## Automation Pilot
resource "btp_subaccount_entitlement" "auto_pilot" {
  subaccount_id = var.subaccount_id

  service_name  = local.service_name__auto_pilot
  plan_name     = local.service_plan__auto_pilot
}

resource "btp_subaccount_subscription" "auto_pilot" {
  subaccount_id = var.subaccount_id
  
  app_name      = local.service_name__auto_pilot
  plan_name     = local.service_plan__auto_pilot
  
  depends_on    = [btp_subaccount_entitlement.auto_pilot]
}

resource "btp_subaccount_role_collection_assignment" "apadmin" {
  subaccount_id        = var.subaccount_id

  role_collection_name = "AutomationPilot_Admin"
  for_each             = toset(var.admins)
  user_name            = each.value
  
  depends_on           = [btp_subaccount_subscription.auto_pilot]
}

resource "btp_subaccount_role_collection_assignment" "apdev" {
  subaccount_id        = var.subaccount_id
  
  role_collection_name = "AutomationPilot_Developer"
  for_each             = toset(var.developers)
  user_name            = each.value

  depends_on           = [btp_subaccount_subscription.auto_pilot]
}