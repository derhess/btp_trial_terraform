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
  
  # Runtime
  service_name__cloudfoundry      = "cloudfoundry"
  service_name__cloudfoundry_plan = "trial"
  service_name__destination       = "destination"

  #Memory in MB for the CF Runtime environment instance
  resources__runtime_memory = 1024

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
# 
# see also https://github.com/btp-automation-scenarios/useful-samples/tree/main/cf-environment-instance-memory
# ------------------------------------------------------------------------------------------------------
# Entitle
resource "btp_subaccount_entitlement" "cf_application_runtime" {
  #count         = var.use_optional_resources ? 1 : 0
  
  subaccount_id = var.subaccount_id
            
  plan_name              = local.service_name__cloudfoundry_plan
  #plan_unique_identifier = "${local.service_name__cloudfoundry}-trial"
  service_name           = local.service_name__cloudfoundry
}

resource "btp_subaccount_entitlement" "cf_application_memory" {
  subaccount_id = var.subaccount_id
  service_name  = "APPLICATION_RUNTIME"
  plan_name     = "MEMORY"
  amount        = 2
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
    memory = local.resources__runtime_memory
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

resource "cloudfoundry_space" "space" {
  name = var.project_stage
  org  = provider::btp::extract_cf_org_id(btp_subaccount_environment_instance.cf.labels)

  depends_on = [ btp_subaccount_environment_instance.cf ]
}

data "cloudfoundry_space" "space" {
  name = var.project_stage
  org  = provider::btp::extract_cf_org_id(btp_subaccount_environment_instance.cf.labels)

  depends_on = [ cloudfoundry_space.space ]
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

resource "cloudfoundry_org_role" "user_admins" {
  for_each   = toset(var.cf_org_managers)
  username   = each.value
  type       = "organization_user"
  org        = btp_subaccount_environment_instance.cf.platform_id
  
  depends_on = [btp_subaccount_environment_instance.cf]
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

