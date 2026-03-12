output "hana_cloud_tools_dashboard_url" {
  value       = btp_subaccount_subscription.hana_cloud_tools.subscription_url
  description = "The URL of the SAP HANA Cloud Tools dashboard."
}

output "hana_db_password" {
  value       = random_password.password.result
  description = "The password for the SAP HANA database."
  sensitive   = true
}