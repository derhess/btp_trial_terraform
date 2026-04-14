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
  
  # Notification Service based on Monitoring and Alerting for SAP BTP - Alert Notification
  service_name__alert_notification      = "alert-notification"
  service_plan__alert_notification      = "standard"

  # Automation Pilot
  service_name__auto_pilot              = "automationpilot"
  service_plan__auto_pilot              = "free"


  # SAP Cloud Transport Management
  service_name__cloud_transport_management   = "transport"
  service_plan__cloud_transport_management   = "standard"
  service_name__cloud_transport_management_app = "alm-ts"
  service_plan__cloud_transport_management_app = "lite"

  service_name__content_agent-ui           = "content-agent-ui"
  service_plan__content_agent-ui           = "free"
  service_name__content_agent              = "content-agent"
  service_plan__content_agent              = "standard"


  # Audit Log Service - Roles
  service_name__audit_log              = "auditlog-management"
  service_plan__audit_log              = "default"

  # Credential Store
  service_name__credential_store       = "credstore"
  service_plan__credential_store       = "trial"

}


# ------------------------------------------------------------------------------------------------------
# Setup Services
# ------------------------------------------------------------------------------------------------------

## Alert Notification Service - Standard Plan 
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

resource "btp_subaccount_role_collection_assignment" "apadmin-genai" {
  subaccount_id        = var.subaccount_id

  role_collection_name = "AutomationPilot_Admin_With_GenAI"
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

resource "btp_subaccount_role_collection_assignment" "apdev-genai" {
  subaccount_id        = var.subaccount_id
  
  role_collection_name = "AutomationPilot_Developer_With_GenAI"
  for_each             = toset(var.developers)
  user_name            = each.value

  depends_on           = [btp_subaccount_subscription.auto_pilot]
}


############################
## Audi Log Service

# Service Instance for general Cloud Foundry applications
data "btp_subaccount_service_plan" "audit_log" {
  subaccount_id = var.subaccount_id
  
  offering_name = local.service_name__audit_log
  name          = local.service_plan__audit_log
}

# Create service instance
resource "btp_subaccount_service_instance" "audit_log"{
   subaccount_id  = var.subaccount_id
   
   serviceplan_id = data.btp_subaccount_service_plan.audit_log.id
   
   name           = "${local.service_name_prefix}-auditlog-mnt"
   
  depends_on = [
    data.btp_subaccount_service_plan.audit_log
  ]
}
######################
## SAP Cloud Transport Management - Standard Plan

resource "btp_subaccount_entitlement" "sctm" {
  subaccount_id = var.subaccount_id

  service_name  = local.service_name__cloud_transport_management
  plan_name     = local.service_plan__cloud_transport_management
}

resource "btp_subaccount_entitlement" "sctm-lite" {
  subaccount_id = var.subaccount_id

  service_name  = local.service_name__cloud_transport_management_app
  plan_name     = local.service_plan__cloud_transport_management_app
}

data "btp_subaccount_service_plan" "sctm" {
  subaccount_id = var.subaccount_id
  
  offering_name = local.service_name__cloud_transport_management
  name          = local.service_plan__cloud_transport_management

  depends_on = [ btp_subaccount_entitlement.sctm ]
}

# Create service instance
resource "btp_subaccount_service_instance" "sctm"{
   subaccount_id  = var.subaccount_id
   
   serviceplan_id = data.btp_subaccount_service_plan.sctm.id
   
   name           = "${local.service_name_prefix}-sctm"
   
  depends_on = [
    data.btp_subaccount_service_plan.sctm
  ]
}

# Cloud Transport Management Dashboard Application
resource "btp_subaccount_subscription" "sctm" {
  subaccount_id = var.subaccount_id
  
  app_name      = local.service_name__cloud_transport_management_app
  plan_name     = local.service_plan__cloud_transport_management_app
  
  depends_on    = [btp_subaccount_entitlement.sctm-lite]
}

resource "btp_subaccount_role_collection_assignment" "sctm_admin" {
  subaccount_id        = var.subaccount_id

  role_collection_name = "TMS_LandscapeOperator_RC"
  for_each             = toset(var.admins)
  user_name            = each.value
  
  depends_on           = [btp_subaccount_subscription.sctm]
}

resource "btp_subaccount_role_collection_assignment" "sctm_viewer" {
  subaccount_id        = var.subaccount_id

  role_collection_name = "TMS_Viewer_RC"
  for_each             = toset(var.developers)
  user_name            = each.value
  
  depends_on           = [btp_subaccount_subscription.sctm]
}

# Content Agent Service - Related zo SAP Cloud Transport Management and SAP Integration Suite
resource "btp_subaccount_entitlement" "content-agent" {
  subaccount_id = var.subaccount_id

  service_name  = local.service_name__content_agent
  plan_name     = local.service_plan__content_agent
}

resource "btp_subaccount_entitlement" "sctm-content-agent-ui" {
  subaccount_id = var.subaccount_id

  service_name  = local.service_name__content_agent-ui
  plan_name     = local.service_plan__content_agent-ui  
}


data "btp_subaccount_service_plan" "content-agent" {
  subaccount_id = var.subaccount_id
  
  offering_name = local.service_name__content_agent
  name          = local.service_plan__content_agent

  depends_on = [ btp_subaccount_entitlement.content-agent ]
}

# Create service instance
resource "btp_subaccount_service_instance" "content-agent"{
   subaccount_id  = var.subaccount_id
   
   serviceplan_id = data.btp_subaccount_service_plan.content-agent.id
   
   name           = "${local.service_name_prefix}-content-agent"
   
  depends_on = [
    data.btp_subaccount_service_plan.content-agent
  ]
}

# Cloud Transport Management Dashboard Application
resource "btp_subaccount_subscription" "content-agent-ui" {
  subaccount_id = var.subaccount_id
  
  app_name      = local.service_name__content_agent-ui
  plan_name     = local.service_plan__content_agent-ui
  
  depends_on    = [btp_subaccount_entitlement.sctm-content-agent-ui]
}


resource "btp_subaccount_role_collection_assignment" "content-agent_admin" {
  subaccount_id        = var.subaccount_id

  role_collection_name = "Content Agent Admin"
  for_each             = toset(var.admins)
  user_name            = each.value
  
  depends_on           = [btp_subaccount_subscription.sctm]
}

resource "btp_subaccount_role_collection_assignment" "content-agent_import" {
  subaccount_id        = var.subaccount_id

  role_collection_name = "Content Agent Import Operator"
  for_each             = toset(var.admins)
  user_name            = each.value
  
  depends_on           = [btp_subaccount_subscription.sctm]
}

resource "btp_subaccount_role_collection_assignment" "content-agent_export" {
  subaccount_id        = var.subaccount_id

  role_collection_name = "Content Agent Export Operator"
  for_each             = toset(var.admins)
  user_name            = each.value
  
  depends_on           = [btp_subaccount_subscription.sctm]
}

resource "btp_subaccount_role_collection_assignment" "content-agent_viewer" {
  subaccount_id        = var.subaccount_id

  role_collection_name = "Content Agent Viewer"
  for_each             = toset(var.developers)
  user_name            = each.value
  
  depends_on           = [btp_subaccount_subscription.sctm]
}

#####
# Credential Store
resource "btp_subaccount_entitlement" "credential_store" {
  subaccount_id = var.subaccount_id

  service_name  = local.service_name__credential_store
  plan_name     = local.service_plan__credential_store

  amount = 1
}
/*
data "btp_subaccount_service_plan" "credential_store" {
  subaccount_id = var.subaccount_id
  
  name          = local.service_plan__credential_store
  offering_name = local.service_name__credential_store
  
  depends_on    = [btp_subaccount_entitlement.credential_store]
}

resource "btp_subaccount_service_instance" "credential_store" {
  subaccount_id  = var.subaccount_id
  
  serviceplan_id = data.btp_subaccount_service_plan.credential_store.id
  name           = "${local.service_name_prefix}-${local.service_name__credential_store}"

  depends_on = [ data.btp_subaccount_service_plan.credential_store ]
}
*/
#Cloud Foundry specific Service Instance for Credential Store
data "cloudfoundry_service_plan" "cf_cred_api" {
  service_offering_name = local.service_name__credential_store
  name                  = local.service_plan__credential_store

  depends_on = [ btp_subaccount_entitlement.credential_store]
}


# Instance creation
resource "cloudfoundry_service_instance" "cf_cred_api" {
  
  name         = local.service_name__credential_store
  service_plan = data.cloudfoundry_service_plan.cf_cred_api.id
  
  space        = var.cf_space_id

  type         = "managed"
  
  timeouts = {
    create = "5m"
    delete = "5m"
    update = "5m"
  }

  depends_on = [ data.cloudfoundry_service_plan.cf_cred_api ]
}


# User Roles - Credential Store
locals {
  role_collection_credential_viewer = "Service_Credential_Viewer"
}

resource "btp_subaccount_role_collection" "credential_viewer" {
  subaccount_id = var.subaccount_id
  name          = local.role_collection_credential_viewer
  description   = "Service Credential Viewer Role Collection"

  roles = [
    {
      name                 = "Service Credentials Viewer"
      role_template_app_id = "service-manager!b1476"
      role_template_name   = "Service_Credentials_Viewer"
    }
  ]
  depends_on = [ cloudfoundry_service_instance.cf_cred_api ]
}

resource "btp_subaccount_role_collection_assignment" "credential_viewer" {
  for_each             = toset("${var.developers}")
  subaccount_id        = var.subaccount_id
  role_collection_name = local.role_collection_credential_viewer
  user_name            = each.value

  depends_on           = [btp_subaccount_role_collection.credential_viewer]
}