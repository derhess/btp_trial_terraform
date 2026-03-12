resource "random_uuid" "uuid" {}

data "btp_globalaccount" "this" {}

locals {
  subaccount_name      = "${var.subaccount_stage} ${var.project_name}"
  subaccount_subdomain = join("-", [lower(replace("${var.subaccount_stage}-${var.project_name}", " ", "-")), random_uuid.uuid.result])
  beta_enabled         = var.subaccount_stage == "PROD" ? false : true
  subaccount_cf_org    = local.subaccount_subdomain
}



# ------------------------------------------------------------------------------------------------------
# Creation of Modules
# ------------------------------------------------------------------------------------------------------

module "subaccount" {
  source                      = "./modules/subaccount"
  project_name                = var.project_name
  project_stage               = var.subaccount_stage
  subaccount_admins           = var.subaccount_admins
  subaccount_emergency_admins = var.subaccount_emergency_admins
  subaccount_developers       = var.subaccount_developers
}

# ------------------------------------------------------------------------------------------------------
# Identity Authentication and Authorization
# ------------------------------------------------------------------------------------------------------
# Step 2
/* module "identity" {
  source = "./modules/sec_identity"

  subaccount_id = module.subaccount.subaccount_id

  project_name  = var.project_name
  project_stage = var.subaccount_stage

  depends_on = [module.subaccount]
}
*/
/*

# ------------------------------------------------------------------------------------------------------
# Database Services - Persistent Storage
# ------------------------------------------------------------------------------------------------------
module "hana_db" {
  source            = "./modules/db_hana"
  subaccount_id     = module.subaccount.subaccount_id
  
  project_name      = var.project_name
  project_stage     = var.subaccount_stage
  
  developers        = var.subaccount_developers
  admins            = var.subaccount_admins

  depends_on        = [module.identity]
}
/*
module "postgresql_db" {
  source            = "./modules/db_postgresql"
  subaccount_id     = module.subaccount.subaccount_id
  
  project_name      = var.project_name
  project_stage     = var.subaccount_stage
  
  admins            = var.subaccount_admins

  depends_on        = [module.identity]
}*/



# ------------------------------------------------------------------------------------------------------
# Runtime Environments
# ------------------------------------------------------------------------------------------------------
# STEP 2
/*
module "cloud_foundry" {
  source            = "./modules/runtime_cf"

  subaccount_id     = module.subaccount.subaccount_id
  subaccount_region = var.subaccount_region

  project_name      = var.project_name
  project_stage     = var.subaccount_stage

  cf_landscape_label  = var.cf_landscape_label
  #cf_org_managers     = var.subaccount_admins
  cf_space_managers   = var.subaccount_admins
  cf_space_developers = var.subaccount_developers

  depends_on        = [module.identity]
}

module "abap_cloud" {
  source            = "./modules/runtime_abap"

  subaccount_id     = module.subaccount.subaccount_id
  cf_space_id       = module.cloud_foundry.cf_space_id
  
  abap_admin_email  = var.subaccount_admins[0]

  depends_on        = [module.cloud_foundry]
}

module "application_frontend_service" {
  source            = "./modules/runtime_afs"

  subaccount_id     = module.subaccount.subaccount_id
  developers        = var.subaccount_developers

  depends_on        = [module.cloud_foundry]
}*/

# Workflow Engine
/*
module "process_automation" {
  source            = "./modules/dev_process_auto"

  subaccount_id     = module.subaccount.subaccount_id

  process_automation_admins = var.subaccount_admins
  process_automation_delegates = var.subaccount_admins
  process_automation_experts = var.subaccount_developers
  process_automation_developers = var.subaccount_developers
  process_automation_participants = var.subaccount_developers

  depends_on        = [module.cloud_foundry]
}
*/

# ------------------------------------------------------------------------------------------------------
# E2E - SasS Services
# ------------------------------------------------------------------------------------------------------
# Step 2
/*
module "workzone" {
  source            = "./modules/workzone"
  subaccount_id     = module.subaccount.subaccount_id
  
  project_name      = var.project_name
  project_stage     = var.subaccount_stage
  launchpad_admins  = var.launchpad_admins
  custom_idp_origin = module.identity.idp_origin

  depends_on        = [module.identity]
}
*/
# ------------------------------------------------------------------------------------------------------
# Software Development - Build and Deploy Services
# ------------------------------------------------------------------------------------------------------
/* STEP 3 */
/*
module "application_studio" {
  source            = "./modules/dev_bas"

  subaccount_id     = module.subaccount.subaccount_id
  
  bas_developers    = var.subaccount_developers
  bas_admins        = var.subaccount_admins

  depends_on        = [module.subaccount]
}


module "build_code" {
  source            = "./modules/dev_build_code"

  subaccount_id     = module.subaccount.subaccount_id
  
  developers        = var.subaccount_developers
  admins            = var.subaccount_admins

  depends_on        = [module.cloud_foundry, module.application_studio]
}


# Low Code/No Code Tools
module "build_apps" {
  source            = "./modules/dev_build_apps"

  subaccount_id     = module.subaccount.subaccount_id
  
  developers        = var.subaccount_developers
  admins            = var.subaccount_admins

  depends_on        = [module.build_code]
}

#Other services
module "dev_saas" {
  source            = "./modules/dev_services"

  subaccount_id     = module.subaccount.subaccount_id
  cf_space_id       = module.cloud_foundry.cf_space_id

  project_name      = var.project_name
  project_stage     = var.subaccount_stage

  developers        = var.subaccount_developers
  admins            = var.subaccount_admins
  auditors          = var.subaccount_admins
  
  depends_on        = [module.cloud_foundry]
}

*/

# ------------------------------------------------------------------------------------------------------
# Infrastructure Services - Automation Pilot, Monitoring, Alerting, Logging, etc.
# ------------------------------------------------------------------------------------------------------
#Step 4
/*
module "infra_mobile" {
  source            = "./modules/infra_mobile"

  subaccount_id     = module.subaccount.subaccount_id
  cf_space_id       = module.cloud_foundry.cf_space_id

  depends_on        = [module.cloud_foundry]
}

module "infra_saas" {
  source            = "./modules/infra_services"

  subaccount_id     = module.subaccount.subaccount_id

  project_name      = var.project_name
  project_stage     = var.subaccount_stage

  admins            = var.subaccount_admins
  developers        = var.subaccount_developers
  
  depends_on        = [module.cloud_foundry]
}*/
