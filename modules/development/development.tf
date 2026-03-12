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
  project_subaccount_cf_org = "${local.service_name_prefix}-cf-org"
  # Development Tools
  service_name__sap_build_code = "build-code"
  service_name__sap_app_studio = "sapappstudiotrial"
  # service_name__sap_build_apps = "sap-build-apps"

  # Runtime
  service_name__abap      = "abap-trial"
  service_name__abap_plan = "shared"

  service_name__cloudfoundry      = "cloudfoundry"
  service_name__cloudfoundry_plan = "trial"
  service_name__destination       = "destination"

  service_name__application_frontend      = "application-frontend"
  service_name__application_frontend_plan = "trial"

  service_name__process_automation      = "process-automation"
  service_name__process_automation_plan = "free"

  # optional, if custom idp is used
  service_name__sap_identity_services_onboarding = "sap-identity-services-onboarding"
}

locals {
  origin_key = data.btp_whoami.me.issuer != var.custom_idp ? "sap.default" : var.custom_idp
}


# ------------------------------------------------------------------------------------------------------
# Setup destination (Destination Service)
# ------------------------------------------------------------------------------------------------------
# Entitle
resource "btp_subaccount_entitlement" "destination" {
  subaccount_id = var.subaccount_id
  service_name  = local.service_name__destination
  plan_name     = "lite"
}


# ------------------------------------------------------------------------------------------------------
# Setup APPLICATION_RUNTIME (Cloud Foundry Runtime)
# ------------------------------------------------------------------------------------------------------
# Entitle
resource "btp_subaccount_entitlement" "cf_application_runtime" {
  #count         = var.use_optional_resources ? 1 : 0
  
  subaccount_id = var.subaccount_id
            
  plan_name              = local.service_name__cloudfoundry_plan
  #plan_unique_identifier = "${local.service_name__cloudfoundry}-trial"
  service_name           = local.service_name__cloudfoundry
}

# ------------------------------------------------------------------------------------------------------
# Setup cloudfoundry (Cloud Foundry Environment)
# ------------------------------------------------------------------------------------------------------
# Fetch all available environments for the subaccount
# Retrieval of existing CF environment instance
data "btp_subaccount_environment_instances" "all" {
  subaccount_id = var.subaccount_id
}

resource "btp_subaccount_environment_instance" "cf" {

  subaccount_id    = var.subaccount_id
  name             = local.project_subaccount_cf_org
  environment_type = local.service_name__cloudfoundry
  service_name     = local.service_name__cloudfoundry
  plan_name        = local.service_name__cloudfoundry_plan
  landscape_label  = "cf-us10-001"
  #landscape_label  = terraform_data.cf_landscape_label.output

  parameters = jsonencode({
    instance_name = local.project_subaccount_cf_org
    landscapeLabel = "cf-us10-001"
    users = [{
      email = "florianweil@gmx.de"
    }]
  })

  depends_on = [ btp_subaccount_entitlement.cf_application_runtime ]
}
locals {
  cf_org_id = provider::btp::extract_cf_org_id(btp_subaccount_environment_instance.cf.labels)
  cf_api_url = provider::btp::extract_cf_api_url(btp_subaccount_environment_instance.cf.labels)
  
  depends_on = [ btp_subaccount_environment_instance.cf ]
}


# ------------------------------------------------------------------------------------------------------
# Create the Cloud Foundry space
# ------------------------------------------------------------------------------------------------------

resource "cloudfoundry_space" "space_name" {
  name = var.project_stage
  org  = provider::btp::extract_cf_org_id(btp_subaccount_environment_instance.cf.labels)

  depends_on = [ btp_subaccount_environment_instance.cf ]
}

data "cloudfoundry_space" "space" {
  name = var.project_stage
  org  = provider::btp::extract_cf_org_id(btp_subaccount_environment_instance.cf.labels)

  depends_on = [ cloudfoundry_space.space_name ]
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
  depends_on    = [data.cloudfoundry_space.space]
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
  
  space        = data.cloudfoundry_space.space.id

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
# Setup Application Frontend Service Trial
# ------------------------------------------------------------------------------------------------------
# Entitle
resource "btp_subaccount_entitlement" "app_frontend" {
  subaccount_id = var.subaccount_id
  service_name  = local.service_name__application_frontend
  plan_name     = local.service_name__application_frontend_plan

  depends_on    = [data.cloudfoundry_space.space]
}

# Instance creation
resource "btp_subaccount_subscription" "app_frontend" {

  subaccount_id = var.subaccount_id
  
  app_name      = local.service_name__application_frontend
  plan_name     = local.service_name__application_frontend_plan
  
  depends_on = [btp_subaccount_entitlement.app_frontend]
}

# ------------------------------------------------------------------------------------------------------
# Setup SAP Build Process Automation - Trial
# ------------------------------------------------------------------------------------------------------
# Entitle
resource "btp_subaccount_entitlement" "process_automation" {
  subaccount_id = var.subaccount_id
  service_name  = local.service_name__process_automation
  plan_name     = local.service_name__process_automation_plan

  depends_on    = [data.cloudfoundry_space.space]
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
# Setup sap_app_studio (SAP Business Application Studio)
# ------------------------------------------------------------------------------------------------------
module "bas" {
  source                  = "./bas"
  subaccount_id           = var.subaccount_id
  bas_admins              = var.cf_space_managers
  bas_developers          = var.cf_space_developers
}

# ------------------------------------------------------------------------------------------------------
# Setup SAP Build Code 
# ------------------------------------------------------------------------------------------------------
module "build_code" {
  source                  = "./build_code"
  subaccount_id           = var.subaccount_id
  admins                  = var.cf_space_managers
  developers              = var.cf_space_developers
}

# ------------------------------------------------------------------------------------------------------
# Setup SAP Build Apps - Low Code/No Code (optional)
# ------------------------------------------------------------------------------------------------------
module "build_apps" {
  source                  = "./build_apps"

  subaccount_id           = var.subaccount_id

  admins                  = var.cf_space_managers
  developers              = var.cf_space_developers
}

# ------------------------------------------------------------------------------------------------------
# Application Lifecycle Services (optional)
# ------------------------------------------------------------------------------------------------------


# ------------------------------------------------------------------------------------------------------
# Mobile Services (CROSS-PLATFORM Service) depends on Cloud Foundry Runtime 
# ------------------------------------------------------------------------------------------------------
locals {
    service_name__mobile_services = "mobile-services"
    service_plan__mobile_services = "lite"
}

# Entitle
resource "btp_subaccount_entitlement" "mobile_services" {
  subaccount_id = var.subaccount_id
  service_name  = local.service_name__mobile_services
  plan_name     = local.service_plan__mobile_services
  #amount        = var.service_plan__mobile_services == "free" ? 1 : null
  amount        = 1
}
# Subscribe

data "cloudfoundry_service_plan" "mobile_services" {
  service_offering_name = local.service_name__mobile_services
  name                  = local.service_plan__mobile_services

  depends_on = [ btp_subaccount_entitlement.mobile_services ]
}


# Instance creation
resource "cloudfoundry_service_instance" "mobile_services" {
  
  name         = local.service_name__mobile_services
  service_plan = data.cloudfoundry_service_plan.mobile_services.id
  
  space        = data.cloudfoundry_space.space.id

  type         = "managed"
  
  timeouts = {
    create = "30m"
    delete = "30m"
    update = "30m"
  }

  depends_on = [ data.cloudfoundry_service_plan.mobile_services, data.cloudfoundry_space.space ]
}

# ------------------------------------------------------------------------------------------------------
# Setup cicd-app (Continuous Integration & Delivery)
# ------------------------------------------------------------------------------------------------------

locals {
  service_name__cicd_service  = "cicd-service"
  service_name__cicd_app      = "cicd-app"
  service_plan__cicd          = "trial"
}

# Entitle
resource "btp_subaccount_entitlement" "cicd_service" {
  subaccount_id = var.subaccount_id

  service_name  = local.service_name__cicd_service
  plan_name     = local.service_plan__cicd

  depends_on    = [data.cloudfoundry_space.space]
  #amount        = var.service_plan__cicd_app == "free" ? 1 : null
}

resource "btp_subaccount_entitlement" "cicd_app" {
  subaccount_id = var.subaccount_id

  service_name  = local.service_name__cicd_app
  plan_name     = local.service_plan__cicd

  depends_on    = [data.cloudfoundry_space.space]
  #amount        = var.service_plan__cicd_app == "free" ? 1 : null
}


# Create app subscription for Continuous Integration & Delivery (depends on entitlement)
resource "btp_subaccount_subscription" "cicd_app" {
  subaccount_id = var.subaccount_id
  
  app_name      = local.service_name__cicd_app
  plan_name     = local.service_plan__cicd

  depends_on    = [btp_subaccount_entitlement.cicd_app]
}

# Create a service instance and service binding of the CI/CD service (for API handling)
/*data "btp_subaccount_service_plan" "cicd_service" {
  subaccount_id = data.btp_subaccount.project.id
  offering_name = "cicd-service"
  name          = "default"
  depends_on    = [btp_subaccount_entitlement.cicd_service]
}
resource "btp_subaccount_service_instance" "cicd_service" {
  subaccount_id  = data.btp_subaccount.project.id
  serviceplan_id = data.btp_subaccount_service_plan.cicd_service.id
  name           = "cicdservice"
  parameters     = jsonencode({ "data" : { "role" : "administrator" } })
  depends_on     = [btp_subaccount_subscription.cicd_app]
}

resource "btp_subaccount_service_binding" "cicd_binding" {
  subaccount_id       = data.btp_subaccount.project.id
  service_instance_id = btp_subaccount_service_instance.cicd_service.id
  name                = "cicd_binding"
}
*/


## Feature Flags Service - Lite Plan
/*
resource "btp_subaccount_entitlement" "feature_flags_service_lite" {
  subaccount_id = var.subaccount_id
  service_name  = "feature-flags"
  plan_name     = "lite"
}

resource "btp_subaccount_entitlement" "feature_flags_dashboard_app" {
  subaccount_id = var.subaccount_id
  service_name  = "feature-flags-dashboard"
  plan_name     = "dashboard"
}

resource "btp_subaccount_subscription" "feature_flags_dashboard_app" {
  subaccount_id = var.subaccount_id
  app_name      = "feature-flags-dashboard"
  plan_name     = "dashboard"
  depends_on    = [btp_subaccount_entitlement.feature_flags_dashboard_app]
}

TODO: feature_flasgs_service_lite erstellen in Cloud Foundry DEV Space als Instance, erst dann verbindet sich das Dashbord
TODO: Feature Flag Admin Role und Auditor Role zu weisen und vorher eine Role Collection erstellen

*/
/*
## Alert Notification Service - Standard Plan

resource "btp_subaccount_entitlement" "alert_notification_service_standard" {
  subaccount_id = var.subaccount_id
  service_name  = "alert-notification"
  plan_name     = "standard"
}

data "btp_subaccount_service_plan" "alert_notification_service_standard" {
  subaccount_id = var.subaccount_id
  name          = "standard"
  offering_name = "alert-notification"
  depends_on    = [btp_subaccount_entitlement.alert_notification_service_standard]
}

resource "btp_subaccount_service_instance" "alert_notification_service_standard" {
  subaccount_id  = var.subaccount_id
  serviceplan_id = data.btp_subaccount_service_plan.alert_notification_service_standard.id
  name           = "${local.service_name_prefix}-alert-notification"
}
*/


# ------------------------------------------------------------------------------------------------------
#  USERS AND ROLES
# ------------------------------------------------------------------------------------------------------
#
# Get all roles in the subaccount

data "btp_subaccount_roles" "all" {
  subaccount_id = var.subaccount_id
  #depends_on    = [btp_subaccount_subscription.sap_build_apps]
}

# ------------------------------------------------------------------------------------------------------
# cf_org_managers: Assign organization_manager role
# ------------------------------------------------------------------------------------------------------
resource "cloudfoundry_org_role" "org_managers" {
  for_each = toset(var.cf_org_managers)
  username = each.value
  type     = "organization_manager"
  org      = provider::btp::extract_cf_org_id(btp_subaccount_environment_instance.cf.labels)

  depends_on = [ btp_subaccount_environment_instance.cf ]
}

# ------------------------------------------------------------------------------------------------------
# cf_space_managers: Assign space_manager role
# ------------------------------------------------------------------------------------------------------
resource "cloudfoundry_space_role" "space_managers" {
  for_each = toset(var.cf_space_managers)
  username = each.value
  type     = "space_manager"
  space    = data.cloudfoundry_space.space.id

  depends_on = [ data.cloudfoundry_space.space ]
}

# ------------------------------------------------------------------------------------------------------
# cf_space_developers: Assign space_developer role
# ------------------------------------------------------------------------------------------------------
resource "cloudfoundry_space_role" "space_developers" {
  for_each = toset(var.cf_space_developers)
  username = each.value
  type     = "space_developer"
  space    = data.cloudfoundry_space.space.id

  depends_on = [ data.cloudfoundry_space.space ]
}

# ------------------------------------------------------------------------------------------------------
# Assign role collection "Application Frontend Service Developer"
# ------------------------------------------------------------------------------------------------------
locals {
  role_collection_application_frontend_developer = "application-frontend-developer"
}
resource "btp_subaccount_role_collection" "application_frontend_developer" {
  subaccount_id = var.subaccount_id
  name          = local.role_collection_application_frontend_developer
  description   = "Developer role collection for Application Frontend Service"

  roles = [
    {
      name                 = "Application_Frontend_Developer"
      role_template_app_id = "us10-appfront!b415322"
      role_template_name   = "Application_Frontend_Developer"
    },
    {
      name                 = "Application_Frontend_Viewer"
      role_template_app_id = "us10-appfront!b415322"
      role_template_name   = "Application_Frontend_Viewer"
    }
  ]
  depends_on = [ btp_subaccount_subscription.app_frontend ]
}

resource "btp_subaccount_role_collection_assignment" "application_frontend_developer" {
  for_each             = toset("${var.build_code_developers}")
  subaccount_id        = var.subaccount_id
  role_collection_name = local.role_collection_application_frontend_developer
  user_name            = each.value

  depends_on           = [btp_subaccount_role_collection.application_frontend_developer]
}

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

# ------------------------------------------------------------------------------------------------------
# Assign role collection "CICD Service Administrator"
# ------------------------------------------------------------------------------------------------------
# optional app subscription
/*
resource "btp_subaccount_role_collection_assignment" "cicd_admins" {
  for_each             = toset(var.use_optional_resources == true ? var.cicd_admins : [])
  subaccount_id        = data.btp_subaccount.dc_mission.id
  role_collection_name = "CICD Service Administrator"
  user_name            = each.value
  depends_on           = [btp_subaccount_subscription.cicd_app]
}
*/
# ------------------------------------------------------------------------------------------------------
# Assign role collection "CICD Service Developer"
# ------------------------------------------------------------------------------------------------------
# optional app subscription
/*resource "btp_subaccount_role_collection_assignment" "cicd_developers" {
  for_each             = toset(var.use_optional_resources == true ? var.cicd_developers : [])
  subaccount_id        = data.btp_subaccount.dc_mission.id
  role_collection_name = "CICD Service Developer"
  user_name            = each.value
  depends_on           = [btp_subaccount_subscription.cicd_app]
}*/





