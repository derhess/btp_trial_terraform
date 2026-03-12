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

  service_name__cicd_application      = "cicd-app"
  service_name__cicd_service          = "cicd-service"
  service_plan__cicd                  = "trial"

  service_name__feature_flags_service = "feature-flags"
  service_plan__feature_flags_service = "lite"
  service_name__feature_flags_dashboard = "feature-flags-dashboard"
  service_plan__feature_flags_dashboard = "dashboard"

  # TODO: add THEME DESIGNER

  

  # TODO: add APPLICATION LOGGING

  # TODO: add APPLICATION SCALER #optional

}


# ------------------------------------------------------------------------------------------------------
# Continuous Integration & Delivery
# ------------------------------------------------------------------------------------------------------

# Entitle subaccount for usage of app Continuous Integration & Delivery
resource "btp_subaccount_entitlement" "cicd_app" {
  subaccount_id = var.subaccount_id
  
  service_name  = local.service_name__cicd_application
  plan_name     = local.service_plan__cicd

  amount       = 1
}

# Entitle subaccount for usage of service Continuous Integration & Delivery
/*resource "btp_subaccount_entitlement" "cicd_service" {
  subaccount_id = var.subaccount_id
  
  service_name  = local.service_name__cicd_service
  plan_name     = local.service_plan__cicd
}*/

# Create app subscription for Continuous Integration & Delivery (depends on entitlement)
resource "btp_subaccount_subscription" "cicd_app" {
  subaccount_id = var.subaccount_id
  
  app_name      = local.service_name__cicd_application
  plan_name     = local.service_plan__cicd
  
  depends_on    = [btp_subaccount_entitlement.cicd_app]
}

# Create a service instance and service binding of the CI/CD service (for API handling)
/*data "btp_subaccount_service_plan" "cicd_service" {
  
  subaccount_id = var.subaccount_id

  offering_name = local.service_name__cicd_service
  name          = local.service_plan__cicd
  
  #depends_on    = [btp_subaccount_entitlement.cicd_service]
  depends_on    = [btp_subaccount_entitlement.cicd_app]
}

resource "btp_subaccount_service_instance" "cicd_service" {
  subaccount_id  = var.subaccount_id
  
  serviceplan_id = data.btp_subaccount_service_plan.cicd_service.id
  name           = "${local.service_name_prefix}-cicdservice"

  parameters     = jsonencode({ "data" : { "role" : "administrator" } })
  
  depends_on     = [btp_subaccount_subscription.cicd_app]
}

resource "btp_subaccount_service_binding" "cicd_binding" {
  subaccount_id       = var.subaccount_id
  service_instance_id = btp_subaccount_service_instance.cicd_service.id
  name                = "cicd_binding"
}
*/


###################################################################
# Map user to CI/CD roles
resource "btp_subaccount_role_collection_assignment" "cicdadmin" {
  subaccount_id        = var.subaccount_id
  
  role_collection_name = "CICD Service Administrator"
  for_each             = toset(var.admins)
  user_name            = each.value

  depends_on           = [btp_subaccount_subscription.cicd_app]
}

resource "btp_subaccount_role_collection_assignment" "cicddev" {
  subaccount_id        = var.subaccount_id
  
  role_collection_name = "CICD Service Developer"
  for_each             = toset(var.developers)
  user_name            = each.value

  depends_on           = [btp_subaccount_subscription.cicd_app]
}


# ------------------------------------------------------------------------------------------------------
# Feature Flag Service
# ------------------------------------------------------------------------------------------------------
resource "btp_subaccount_entitlement" "feature_flags_service_lite" {
  subaccount_id = var.subaccount_id
  service_name  = local.service_name__feature_flags_service
  plan_name     = local.service_plan__feature_flags_service
}

resource "btp_subaccount_entitlement" "feature_flags_dashboard_app" {
  subaccount_id = var.subaccount_id
  service_name  = local.service_name__feature_flags_dashboard
  plan_name     = local.service_plan__feature_flags_dashboard
}

resource "btp_subaccount_subscription" "feature_flags_dashboard_app" {
  subaccount_id = var.subaccount_id
  app_name      = local.service_name__feature_flags_dashboard
  plan_name     = local.service_plan__feature_flags_dashboard
  depends_on    = [btp_subaccount_entitlement.feature_flags_dashboard_app]
}

data "btp_subaccount_service_plan" "feature_flags_service" {
  
  subaccount_id = var.subaccount_id

  offering_name = local.service_name__feature_flags_service
  name          = local.service_plan__feature_flags_service
  
  #depends_on    = [btp_subaccount_entitlement.cicd_service]
  depends_on    = [btp_subaccount_entitlement.feature_flags_service_lite]
}

resource "btp_subaccount_service_instance" "feature_flags_service" {
  subaccount_id  = var.subaccount_id
  
  serviceplan_id = data.btp_subaccount_service_plan.feature_flags_service.id
  name           = "${local.service_name_prefix}-featureflagsservice"
  
  depends_on     = [data.btp_subaccount_service_plan.feature_flags_service]
}

resource "btp_subaccount_service_binding" "feature_flags_binding" {
  subaccount_id       = var.subaccount_id
  service_instance_id = btp_subaccount_service_instance.feature_flags_service.id
  name                = "feature_flags_binding"
}

#Cloud Foundry Service Instance for Feature Flag Service (for dashboard connection)
data "cloudfoundry_service_plan" "feature-flag-service" {
  name                  = local.service_plan__feature_flags_service
  service_offering_name = local.service_name__feature_flags_service

  depends_on = [ btp_subaccount_service_instance.feature_flags_service ]
}

# Managed service instance without parameters
resource "cloudfoundry_service_instance" "feature_flag_service_instance" {
  name         = "cf-feature-flag-service"
  type         = "managed"
  space        = var.cf_space_id
  service_plan = data.cloudfoundry_service_plan.feature-flag-service.id
  timeouts = {
    create = "10m"
  }

  depends_on = [ btp_subaccount_service_instance.feature_flags_service, data.cloudfoundry_service_plan.feature-flag-service ]
}

# Service key creation (for ABAP Development Tools (ADT))
resource "cloudfoundry_service_credential_binding" "feature_flag_service_key" {
  type             = "key"
  name             = "feature_flag_cf_key"
  service_instance = cloudfoundry_service_instance.feature_flag_service_instance.id

  depends_on = [ cloudfoundry_service_instance.feature_flag_service_instance ]
}


###################################################################
## Role assignment for Feature Flag Service
locals {
  role_collection_feature_flag_admin = "feature_flags_admin"
  role_collection_feature_flag_auditor = "feature_flags_auditor"
}

resource "btp_subaccount_role_collection" "feature_flags_admin" {
  subaccount_id = var.subaccount_id
  name          = local.role_collection_feature_flag_admin
  description   = "Feature Flag Service Admin Role Collection"

  roles = [
    {
      name                 = "Feature Flags Service dashboard Administrator"
      role_template_app_id = "feature-flags!b1765"
      role_template_name   = "FeatureFlags_Dashboard_Administrator"
    }
  ]
  depends_on = [ btp_subaccount_subscription.feature_flags_dashboard_app ]
}

resource "btp_subaccount_role_collection_assignment" "feature_flags_admin" {
  for_each             = toset("${var.admins}")
  subaccount_id        = var.subaccount_id
  role_collection_name = local.role_collection_feature_flag_admin
  user_name            = each.value

  depends_on           = [btp_subaccount_role_collection.feature_flags_admin]
}

resource "btp_subaccount_role_collection" "feature_flags_auditor" {
  subaccount_id = var.subaccount_id
  name          = local.role_collection_feature_flag_auditor
  description   = "Feature Flag Service Auditor Role Collection"

  roles = [
    {
      name                 = "Feature Flags Service dashboard Auditor"
      role_template_app_id = "feature-flags!b1765"
      role_template_name   = "FeatureFlags_Dashboard_Auditor"
    }
  ]
  depends_on = [ btp_subaccount_subscription.feature_flags_dashboard_app ]
}

resource "btp_subaccount_role_collection_assignment" "feature_flags_auditor" {
  for_each             = toset("${var.auditors}")
  subaccount_id        = var.subaccount_id
  role_collection_name = local.role_collection_feature_flag_auditor
  user_name            = each.value

  depends_on           = [btp_subaccount_role_collection.feature_flags_auditor]
}
