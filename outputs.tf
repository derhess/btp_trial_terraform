output "subaccount_url" {
  value       = module.subaccount.subaccount_url
  description = "The SAP BTP subaccount URL"
}
/*
output "subaccount_custom_idp_origin" {
  value       = module.identity.idp_origin
  description = "The SAP BTP subaccount custom identity provider origin"
}

output "subaccount_custom_idp_tenant" {
  value       = module.identity.idp_tenant_domain
  description = "The SAP BTP subaccount custom identity provider domain tenant"
}

output "subaccount_custom_idp_admin_url" {
  value       = module.identity.idp_tenant_admin_url
  description = "The SAP BTP subaccount custom Cloud Identity Service admin URL"
}
*/
# ------------------------------------------------------------------------------------------------------
# Runtime Environments
# ------------------------------------------------------------------------------------------------------
#Cloud Foundry Runtime
/*output "cf_api_url" {
  value       = module.cloud_foundry.cf_api_url
  description = "The Cloud Foundry API URL"
}

output "cf_org_id" {
  value       = module.cloud_foundry.cf_org_id
  description = "The Cloud Foundry organization ID"
}

#ABAP Runtime
output "abap_trial_service_instance_id" {
  value       = module.abap_cloud.abap_trial_service_instance_id
  description = "The ID of the ABAP service instance."
}

output "abap_trial_dashboard_url" {
  value       = module.abap_cloud.abap_trial_dashboard_url
  description = "The URL of the ABAP Trial dashboard."
}

output "abap_trial_service_key_id" {
  value       = module.abap_cloud.abap_trial_service_key_id
  description = "The ID of the ABAP service key."
}

# Application Frontend Service Runtime instance
output "application_frontend_dashboard_url" {
  value       = module.application_frontend_service.application_frontend_dashboard_url
  description = "The URL of the Application Frontend Service Dashboard."
}*/

# ------------------------------------------------------------------------------------------------------
# Databases
# ------------------------------------------------------------------------------------------------------
/*
output "hana_cloud_tools_dashboard_url" {
  value       = module.hana_db.hana_cloud_tools_dashboard_url
  description = "The URL of the SAP HANA Cloud Tools dashboard."
}

output "hana_db_password" {
  value       = module.hana_db.hana_db_password
  description = "The password for the SAP HANA database."
  sensitive   = true
}
*/
# ------------------------------------------------------------------------------------------------------
# Additional SAP BTP Services
# ------------------------------------------------------------------------------------------------------
/*
output "sap_launchpad_subscription_url" {
  value       = module.workzone.sap_launchpad_subscription_url
  description = "SAP Build Work Zone, standard edition subscription URL."
}

output "application_studio_dev_space_url" {
  value       = module.application_studio.bas_dev_space_url
  description = "The URL of the SAP Business Application Studio dashboard."
}

output "build_code_dashboard_url" {
  value       = module.build_code.build_code_url
  description = "The URL of the SAP Build Code dashboard."
}

output "cicd_dashboard_url" {
  value       = module.dev_saas.cicd_dashboard_url
  description = "The URL of the Continuous Integration & Delivery Service dashboard."
}

output "feature_flags_dashboard_url" {
  value       = module.dev_saas.feature_flags_dashboard_url
  description = "The URL of the Feature Flags dashboard."
}

output "automation_pilot_dashboard_url" {
  value       = module.infra_saas.automation_pilot_dashboard_url
  description = "The URL of the Automation Pilot dashboard."
}

output "mobile_service_dashboard_url" {
  value       = module.infra_mobile.mobile_service_dashboard_url
  description = "The URL of the SAP Business Application Studio dashboard."
}

*/