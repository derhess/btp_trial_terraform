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
# Create service instance for taskcenter (one-inbox-service)
#
# See sammple https://github.com/SAP-samples/btp-terraform-samples/blob/main/released/discovery_center/mission_3774/step2/main.tf
# ------------------------------------------------------------------------------------------------------
/*
resource "btp_subaccount_entitlement" "taskcenter" {

  subaccount_id = var.subaccount_id

  service_name  = "one-inbox-service"
  plan_name     = "cloud-only-tasks" #free
  #plan_name     = "build-default" 


}

data "cloudfoundry_service_plans" "srvc_taskcenter" {
  service_offering_name = "sap-taskcenter"
  name = "one-inbox-service"
}



resource "cloudfoundry_service_instance" "si_taskcenter" {
  name         = "sap-taskcenter"
  type         = "managed"
  space        = var.cf_space_id
  service_plan = data.cloudfoundry_service_plans.srvc_taskcenter.service_plans[0].id
  parameters = jsonencode({
    "authorities" : [],
    "defaultCollectionQueryFilter" : "own"
  })
  
  depends_on = [ data.cloudfoundry_service_plans.srvc_taskcenter ]
}

# ------------------------------------------------------------------------------------------------------
# Create service key
# ------------------------------------------------------------------------------------------------------
resource "random_uuid" "service_key_stc" {}

resource "cloudfoundry_service_credential_binding" "sap-taskcenter" {
  type             = "key"
  name             = join("_", ["defaultKey", random_uuid.service_key_stc.result])
  service_instance = cloudfoundry_service_instance.si_taskcenter.id

  depends_on = [cloudfoundry_service_instance.si_taskcenter]
}

# ------------------------------------------------------------------------------------------------------
# Prepare and setup service: destination
# ------------------------------------------------------------------------------------------------------
# Entitle subaccount for usage of service destination
resource "btp_subaccount_entitlement" "destination" {
  subaccount_id = var.subaccount_id
  service_name  = "destination"
  plan_name     = "lite"
}
# Get serviceplan_id for stc-service with plan_name "default"
data "btp_subaccount_service_plan" "destination" {
  subaccount_id = var.subaccount_id
  offering_name = "destination"
  name          = "lite"
  depends_on    = [btp_subaccount_entitlement.destination]
}
# Create service instance
resource "btp_subaccount_service_instance" "destination" {
  subaccount_id  = var.subaccount_id
  serviceplan_id = data.btp_subaccount_service_plan.destination.id
  name           = "destination"
  depends_on     = [data.btp_subaccount_service_plan.destination]
  parameters = jsonencode({
    HTML5Runtime_enabled = true
    init_data = {
      subaccount = {
        existing_destinations_policy = "update"
        destinations = [
          {
            Description = "[Do not delete] SAP Task Center - Dummy destination"
            Type        = "HTTP"
            #            clientId                   = "${jsondecode(cloudfoundry_service_credential_binding.sap-taskcenter)["uaa"]["clientid"]}"
            #            clientSecret               = "${jsondecode(cloudfoundry_service_credential_binding.sap-taskcenter)["uaa"]["clientsecret"]}"
            "HTML5.DynamicDestination" = true
            Authentication             = "OAuth2JWTBearer"
            Name                       = "stc-destination"
            #            tokenServiceURL            = "${jsondecode(cloudfoundry_service_credential_binding.sap-taskcenter)["uaa"]["url"]}"
            ProxyType = "Internet"
            #            URL                        = "${jsondecode(cloudfoundry_service_credential_binding.sap-taskcenter.credentials)["url"]}"
            tokenServiceURLType = "Dedicated"
          }
        ]
      }
    }
  })
}
*/


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

# Exampole of role collection assignment with custom IDP origin!
/*resource "btp_subaccount_role_collection_assignment" "process_automation_participants" {
  for_each             = toset(local.process_automation_admins)
  subaccount_id        = data.btp_subaccount.dc_mission.id
  role_collection_name = "ProcessAutomationParticipant"
  user_name            = each.value
  origin               = var.custom_idp_apps_origin_key
  depends_on           = [btp_subaccount_subscription.build_process_automation]
}*/