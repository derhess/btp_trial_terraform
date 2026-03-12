# ------------------------------------------------------------------------------------------------------
# ABAP Runtime
# ------------------------------------------------------------------------------------------------------
/*output "abap_admin_email" {
  value       = var.abap_admin_email
  description = "Email of the ABAP Administrator."
}

output "abab_trial_service_instance_id" {
  value       = cloudfoundry_service_instance.abap_trial.id
  description = "The ID of the ABAP service instance."
}

output "abap_trial_dashboard_url" {
  value       = cloudfoundry_service_instance.abap_trial.dashboard_url
  description = "The URL of the ABAP Trial dashboard."
}

output "abab_trial_service_key_id" {
  value       = cloudfoundry_service_credential_binding.abap_trial_service_key.id
  description = "The ID of the ABAP service key."
}*/

# ------------------------------------------------------------------------------------------------------
# Cloud Foundry Runtime
# ------------------------------------------------------------------------------------------------------

output "cf_api_url" {
  description = "API URL of the Cloud Foundry environment instance"
  value       = provider::btp::extract_cf_api_url(btp_subaccount_environment_instance.cf.labels)
}

output "cf_org_id" {
  description = "Org ID of the Cloud Foundry environment instance"
  value       = provider::btp::extract_cf_org_id(btp_subaccount_environment_instance.cf.labels)
}

# ------------------------------------------------------------------------------------------------------
# Application Frontend Service Runtime instance
# ------------------------------------------------------------------------------------------------------
output "application_frontend_dashboard_url" {
  value       = btp_subaccount_subscription.app_frontend.subscription_url
  description = "The URL of the Application Frontend Service Dashboard."
}

# ------------------------------------------------------------------------------------------------------
# ABARuntime
# ------------------------------------------------------------------------------------------------------

output "abap_trial_service_instance_id" {
  value       = cloudfoundry_service_instance.abap_trial.id
  description = "The ID of the ABAP service instance."
}

output "abap_trial_dashboard_url" {
  value       = cloudfoundry_service_instance.abap_trial.dashboard_url
  description = "The URL of the ABAP Trial dashboard."
}

output "abap_trial_service_key_id" {
  value       = cloudfoundry_service_credential_binding.abap_trial_service_key.id
  description = "The ID of the ABAP service key."
}

# ------------------------------------------------------------------------------------------------------
# Services
# ------------------------------------------------------------------------------------------------------
output "application_studio_dev_space_url" {
  value       = module.bas.bas_dev_space_url
  description = "The URL of the SAP Business Application Studio dashboard."
}

output "build_code_dashboard_url" {
  value       = module.build_code.build_code_url
  description = "The URL of the SAP Build Code dashboard."
}

/*
output "cicd_app_subscription_url" {
  value       = btp_subaccount_subscription.cicd_app[0].subscription_url
  description = "Continuous Integration & Delivery subscription URL."
}*/