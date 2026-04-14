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

  # APPLICATION LOGGING
  service_name__application_logging = "application-logs"
  service_plan__application_logging = "lite"

  # APPLICATION SCALER #optional
  service_name__application_scaling = "autoscaler"
  service_plan__application_scaling = "standard"

  # TODO SAP Translation Hub
  service_name__translation_hub = "document-translation"
  service_plan__translation_hub = "trial"

  # THEME DESIGNER
  service_name__themes = "theming"
  service_plan__themes = "standard"

  # TODO  UI5 Flexibility for Key User Adaption
  service_name__ui5_flexibility = "ui5-flexibility-keyuser"
  service_plan__ui5_flexibility = "trial"
}


# ------------------------------------------------------------------------------------------------------
# Continuous Integration & Delivery
#
# see also https://github.com/SAP-samples/btp-terraform-samples/blob/main/released/usecases/devops/README.md
# ------------------------------------------------------------------------------------------------------

# Entitle subaccount for usage of app Continuous Integration & Delivery
resource "btp_subaccount_entitlement" "cicd_app" {
  subaccount_id = var.subaccount_id
  
  service_name  = local.service_name__cicd_application
  plan_name     = local.service_plan__cicd

  amount       = 1
}
/*
# Entitle subaccount for usage of service Continuous Integration & Delivery
resource "btp_subaccount_entitlement" "cicd_service" {
  subaccount_id = var.subaccount_id
  
  service_name  = local.service_name__cicd_service
  #plan_name     = local.service_plan__cicd
  plan_name     = "default"
}*/

# Create app subscription for Continuous Integration & Delivery (depends on entitlement)
resource "btp_subaccount_subscription" "cicd_app" {
  subaccount_id = var.subaccount_id
  
  app_name      = local.service_name__cicd_application
  plan_name     = local.service_plan__cicd
  
  depends_on    = [btp_subaccount_entitlement.cicd_app]
}

# Create a service instance and service binding of the CI/CD service (for API handling)
/*
data "btp_subaccount_service_plan" "cicd_service" {
  
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

  depends_on = [ btp_subaccount_service_instance.cicd_service ]
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

# Service key creation 
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


# ------------------------------------------------------------------------------------------------------
# Application Loggine Service
# ------------------------------------------------------------------------------------------------------
resource "btp_subaccount_entitlement" "application_logging" {
  subaccount_id = var.subaccount_id
  service_name  = local.service_name__application_logging
  plan_name     = local.service_plan__application_logging
}

#Cloud Foundry Service Instance for Application Logging
data "cloudfoundry_service_plan" "application_logging" {
  name                  = local.service_plan__application_logging
  service_offering_name = local.service_name__application_logging

  depends_on = [ btp_subaccount_entitlement.application_logging ]
}

# Managed service instance without parameters
resource "cloudfoundry_service_instance" "application_logging" {
  name         = "cf-app-log"
  type         = "managed"
  space        = var.cf_space_id
  service_plan = data.cloudfoundry_service_plan.application_logging.id
  timeouts = {
    create = "10m"
  }

  depends_on = [ data.cloudfoundry_service_plan.application_logging ]
}

# ------------------------------------------------------------------------------------------------------
# Application Autoscaler 
# ------------------------------------------------------------------------------------------------------
resource "btp_subaccount_entitlement" "application_scaling" {
  subaccount_id = var.subaccount_id
  service_name  = local.service_name__application_scaling
  plan_name     = local.service_plan__application_scaling
}

#Cloud Foundry Service Instance for Application Autoscaler
data "cloudfoundry_service_plan" "application_scaling" {
  name                  = local.service_plan__application_scaling
  service_offering_name = local.service_name__application_scaling

  depends_on = [ btp_subaccount_entitlement.application_scaling ]
}

# Managed service instance without parameters
resource "cloudfoundry_service_instance" "application_scaling" {
  name         = "cf-app-scale"
  type         = "managed"
  space        = var.cf_space_id
  service_plan = data.cloudfoundry_service_plan.application_scaling.id
  timeouts = {
    create = "10m"
  }

  depends_on = [ data.cloudfoundry_service_plan.application_scaling ]
}


# ------------------------------------------------------------------------------------------------------
# Theme Designer 
# ------------------------------------------------------------------------------------------------------
resource "btp_subaccount_entitlement" "theme_designer" {
  subaccount_id = var.subaccount_id
  service_name  = local.service_name__themes
  plan_name     = local.service_plan__themes
}

#Cloud Foundry Service Instance for UI5/Fiori Theme Designer
data "cloudfoundry_service_plan" "theme_designer" {
  name                  = local.service_plan__themes
  service_offering_name = local.service_name__themes

  depends_on = [ btp_subaccount_entitlement.theme_designer ]
}

# Managed service instance without parameters
resource "cloudfoundry_service_instance" "theme_designer" {
  name         = "cf-ui-theming"
  type         = "managed"
  space        = var.cf_space_id
  service_plan = data.cloudfoundry_service_plan.theme_designer.id
  timeouts = {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  depends_on = [ data.cloudfoundry_service_plan.theme_designer ]
}


# ------------------------------------------------------------------------------------------------------
# SAP Translation Hub
# #TODO Move To saas_others
# Tutorial https://community.sap.com/t5/technology-blog-posts-by-members/getting-started-with-document-translation-service-in-sap-cloud-foundry/ba-p/13443241
# ------------------------------------------------------------------------------------------------------
resource "btp_subaccount_entitlement" "translation" {
  subaccount_id = var.subaccount_id
  service_name  = local.service_name__translation_hub
  plan_name     = local.service_plan__translation_hub
}

#Cloud Foundry Service Instance for Translation Hub
data "cloudfoundry_service_plan" "translation" {
  name                  = local.service_plan__translation_hub
  service_offering_name = local.service_name__translation_hub

  depends_on = [ btp_subaccount_entitlement.translation ]
}

# Managed service instance without parameters
resource "cloudfoundry_service_instance" "translation" {
  name         = "cf-app-translation"
  type         = "managed"
  space        = var.cf_space_id
  service_plan = data.cloudfoundry_service_plan.translation.id
  timeouts = {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  depends_on = [ data.cloudfoundry_service_plan.translation ]
}

## Role assignment for SAP Document Translation Hub
locals {
  role_collection_translation_dev = "translation_dev"
}

resource "btp_subaccount_role_collection" "translation_dev" {
  subaccount_id = var.subaccount_id
  name          = local.role_collection_translation_dev
  description   = "Document Translation Role Collection"

  roles = [
    {
      name                 = "Document_Translation"
      role_template_app_id = "document-translation-us10!b1112"
      role_template_name   = "Document_Translation"
    }
  ]
  depends_on = [ cloudfoundry_service_instance.translation ]
}


resource "btp_subaccount_role_collection_assignment" "translation_dev" {
  for_each             = toset("${var.developers}")
  subaccount_id        = var.subaccount_id
  role_collection_name = local.role_collection_translation_dev
  user_name            = each.value

  depends_on           = [ btp_subaccount_role_collection.translation_dev ]
}


# ------------------------------------------------------------------------------------------------------
# SAP UI5 flexibility for Key User
#
# Intro https://youtu.be/YNzrSAx1X7w?t=1715
# ------------------------------------------------------------------------------------------------------
resource "btp_subaccount_entitlement" "flexibility" {
  subaccount_id = var.subaccount_id
  service_name  = local.service_name__ui5_flexibility
  plan_name     = local.service_plan__ui5_flexibility
}

#Cloud Foundry Service Instance for UI5 flexibility
data "cloudfoundry_service_plan" "flexibility" {
  name                  = local.service_plan__ui5_flexibility
  service_offering_name = local.service_name__ui5_flexibility

  depends_on = [ btp_subaccount_entitlement.flexibility ]
}

# Managed service instance without parameters
resource "cloudfoundry_service_instance" "flexibility" {
  name         = "cf-ui-flexibility"
  type         = "managed"
  space        = var.cf_space_id
  service_plan = data.cloudfoundry_service_plan.flexibility.id
  timeouts = {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  depends_on = [ data.cloudfoundry_service_plan.flexibility ]
}


## Role assignment for UI5 Flexibility for Key User
locals {
  role_collection_ui5_flex_admin = "ui5_Flexibility_Admin"
  role_collection_ui5_flex_user  = "ui5_Flexibility_User"
  role_collection_ui5_flex_viewer = "ui5_Flexibility_Viewer"
}

resource "btp_subaccount_role_collection" "flex_ui5_admin" {
  subaccount_id = var.subaccount_id
  name          = local.role_collection_ui5_flex_admin
  description   = "UI5 Flexibility for Key User - Admin Role Collection"

  roles = [
    {
      name                 = "AdminFlexKeyUser"
      role_template_app_id = "ui5-flexibility-keyuser!b1751"
      role_template_name   = "AdminFlexKeyUser"
    },
    {
      name                 = "FlexOperator"
      role_template_app_id = "ui5-flexibility-keyuser!b1751"
      role_template_name   = "FlexOperator"
    },
    {
      name                 = "FlexOperator"
      role_template_app_id = "ui5-flexibility-personalization!b1751"
      role_template_name   = "FlexOperator"
    }
  ]
  depends_on = [ cloudfoundry_service_instance.flexibility ]
}


resource "btp_subaccount_role_collection_assignment" "flex_ui5_admin" {
  for_each             = toset("${var.admins}")
  subaccount_id        = var.subaccount_id
  role_collection_name = local.role_collection_ui5_flex_admin
  user_name            = each.value

  depends_on           = [ btp_subaccount_role_collection.flex_ui5_admin ]
}


resource "btp_subaccount_role_collection" "flex_ui5_user" {
  subaccount_id = var.subaccount_id
  name          = local.role_collection_ui5_flex_user
  description   = "UI5 Flexibility for Key User - User Role Collection"

  roles = [
    {
      name                 = "FlexKeyUser"
      role_template_app_id = "ui5-flexibility-keyuser!b1751"
      role_template_name   = "FlexKeyUser"
    }
  ]
  depends_on = [ cloudfoundry_service_instance.flexibility ]
}


resource "btp_subaccount_role_collection_assignment" "flex_ui5_user" {
  for_each             = toset("${var.developers}")
  subaccount_id        = var.subaccount_id
  role_collection_name = local.role_collection_ui5_flex_user
  user_name            = each.value

  depends_on           = [ btp_subaccount_role_collection.flex_ui5_user ]
}

resource "btp_subaccount_role_collection" "flex_ui5_view_editor" {
  subaccount_id = var.subaccount_id
  name          = local.role_collection_ui5_flex_viewer
  description   = "UI5 Flexibility for Key User - View Editor Role Collection"

  roles = [
    {
      name                 = "FlexPublicViewEditor"
      role_template_app_id = "ui5-flexibility-keyuser!b1751"
      role_template_name   = "FlexPublicViewEditor"
    }
  ]
  depends_on = [ cloudfoundry_service_instance.flexibility ]
}


resource "btp_subaccount_role_collection_assignment" "flex_ui5_view_editor" {
  for_each             = toset("${var.developers}")
  subaccount_id        = var.subaccount_id
  role_collection_name = local.role_collection_ui5_flex_viewer
  user_name            = each.value

  depends_on           = [ btp_subaccount_role_collection.flex_ui5_view_editor ]
}