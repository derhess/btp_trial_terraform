
# ------------------------------------------------------------------------------------------------------
# Application Frontend Service Runtime instance
# ------------------------------------------------------------------------------------------------------
output "application_frontend_dashboard_url" {
  value       = btp_subaccount_subscription.app_frontend.subscription_url
  description = "The URL of the Application Frontend Service Dashboard."
}
