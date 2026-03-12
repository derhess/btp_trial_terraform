
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

output "cf_org_environment" {
  description = "Resource of the Cloud Foundry environment instance"
  value       = resource.btp_subaccount_environment_instance.cf
}


output "cf_space_id" {
  description = "Space ID of the Cloud Foundry environment instance"
  value       = data.cloudfoundry_space.space.id
}

output "cf_space" {
  description = "Space of the Cloud Foundry environment instance"
  value       = resource.cloudfoundry_space.space
}



