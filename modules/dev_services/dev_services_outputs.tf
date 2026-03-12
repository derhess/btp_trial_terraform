
output "cicd_dashboard_url" {
  value       = btp_subaccount_subscription.cicd_app.subscription_url
  description = "The URL of the CI/CD dashboard."
}


output "feature_flags_dashboard_url" {
  value       = btp_subaccount_subscription.feature_flags_dashboard_app.subscription_url
  description = "The URL of the Feature Flags dashboard."
}