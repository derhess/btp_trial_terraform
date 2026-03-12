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
  
  service_name__process_automation      = "process-automation"
  service_name__process_automation_plan = "free"

  origin_key = data.btp_whoami.me.issuer != var.custom_idp ? "sap.default" : var.custom_idp
}


# ------------------------------------------------------------------------------------------------------
# Setup SAP Build Process Automation - Trial
# ------------------------------------------------------------------------------------------------------
# Entitle
resource "btp_subaccount_entitlement" "process_automation" {

  subaccount_id = var.subaccount_id

  service_name  = local.service_name__process_automation
  plan_name     = local.service_name__process_automation_plan


}

# Instance creation
resource "btp_subaccount_subscription" "process_automation" {

  subaccount_id = var.subaccount_id
  
  app_name      = local.service_name__process_automation
  plan_name     = local.service_name__process_automation_plan

  timeouts = {
    create = "25m"
    delete = "15m"
  }
  
  depends_on = [btp_subaccount_entitlement.process_automation]
}



# ------------------------------------------------------------------------------------------------------
#  USERS AND ROLES
# ------------------------------------------------------------------------------------------------------
#


# ------------------------------------------------------------------------------------------------------
# Assign role collection "SAP Process Automation"
# ------------------------------------------------------------------------------------------------------
resource "btp_subaccount_role_collection_assignment" "process_automation_admins" {
  for_each             = toset("${var.process_automation_admins}")
  subaccount_id        = var.subaccount_id
  role_collection_name = "ProcessAutomationAdmin"
  user_name            = each.value
  depends_on           = [btp_subaccount_subscription.process_automation]
}

resource "btp_subaccount_role_collection_assignment" "process_automation_delegates" {
  for_each             = toset("${var.process_automation_delegates}")
  subaccount_id        = var.subaccount_id
  role_collection_name = "ProcessAutomationDelegate"
  user_name            = each.value
  depends_on           = [btp_subaccount_subscription.process_automation]
}

resource "btp_subaccount_role_collection_assignment" "process_automation_developers" {
  for_each             = toset("${var.process_automation_developers}")
  subaccount_id        = var.subaccount_id
  role_collection_name = "ProcessAutomationDeveloper"
  user_name            = each.value
  depends_on           = [btp_subaccount_subscription.process_automation]
}

resource "btp_subaccount_role_collection_assignment" "process_automation_experts" {
  for_each             = toset("${var.process_automation_experts}")
  subaccount_id        = var.subaccount_id
  role_collection_name = "ProcessAutomationExpert"
  user_name            = each.value
  depends_on           = [btp_subaccount_subscription.process_automation]
}

resource "btp_subaccount_role_collection_assignment" "process_automation_participants" {
  for_each             = toset("${var.process_automation_participants}")
  subaccount_id        = var.subaccount_id
  role_collection_name = "ProcessAutomationParticipant"
  user_name            = each.value
  depends_on           = [btp_subaccount_subscription.process_automation]
}