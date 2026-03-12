terraform {
  required_providers {
    btp = {
      source = "SAP/btp"
    }
  }
}


data "btp_globalaccount" "this" {}

locals {
  service_name_prefix = lower(replace("${var.project_stage}-${var.project_name}", " ", "-"))

  service_name = "sap-identity-services-onboarding"
  service_plan_name = "default"
}

# Entitle
resource "btp_subaccount_entitlement" "sap_identity" {
  subaccount_id = var.subaccount_id
  service_name  = local.service_name
  plan_name     = local.service_plan_name
}

resource "btp_subaccount_subscription" "sap_identity" {
  subaccount_id = var.subaccount_id
  app_name      = local.service_name
  plan_name     = local.service_plan_name

  depends_on = [ btp_subaccount_entitlement.sap_identity ]
}

locals {
  custom_idp_tenant_url = trimprefix( trimsuffix( btp_subaccount_subscription.sap_identity.subscription_url, "/admin" ), "https://" )
  custom_idp_origin     = "sap.custom"
  
  depends_on = [ btp_subaccount_subscription.sap_identity ]
}

# create a new fully customized trust configuration for a subaccount 
# for a Custom Identity Provider for Applications

resource "btp_subaccount_trust_configuration" "trust_idp_config" {
  subaccount_id     = var.subaccount_id
  
  /* Example for IAS tenant
  identity_provider        = "av7ej3p22.trial-accounts.ondemand.com"
  link_text                = "av7ej3p22.trial-accounts.ondemand.com"
  name                     = "Custom IAS tenant"
  */
  
  identity_provider = local.custom_idp_tenant_url
  link_text         = local.custom_idp_tenant_url
  name              = "${local.service_name_prefix}-idenitity-service"
  description       = "SAP Custom Identity Service for Applications"
  auto_create_shadow_users = true
  available_for_user_logon = false
  status = "active"

  depends_on = [ btp_subaccount_subscription.sap_identity ]
}
/*
resource "btp_subaccount_security_settings" "subaccount_sec_setting" {
  subaccount_id = var.subaccount_id

  default_identity_provider = "sap.default"

  access_token_validity  = 3600
  refresh_token_validity = 6000

  treat_users_with_same_email_as_same_user = true

  custom_email_domains = ["yourdomain.test"]

  depends_on = [ btp_subaccount_trust_configuration.trust_idp_config ]
}
*/
