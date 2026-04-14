output "automation_pilot_dashboard_url" {
  value       = btp_subaccount_subscription.auto_pilot.subscription_url
  description = "The URL of the Automation Pilot dashboard."
}

output "cloud_transport_management_dashboard_url" {
  value       = btp_subaccount_subscription.sctm.subscription_url
  description = "The URL of the Cloud Transport Management dashboard."
}

output "content_agent_dashboard_url" {
  value       = btp_subaccount_subscription.content-agent-ui.subscription_url
  description = "The URL of the Content Agent dashboard."
}

output "credential_store_dashboard_url" {
  value       = cloudfoundry_service_instance.cf_cred_api.dashboard_url
  description = "The URL of the Credential Store dashboard."
}