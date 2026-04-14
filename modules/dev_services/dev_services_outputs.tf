
output "cicd_dashboard_url" {
  value       = btp_subaccount_subscription.cicd_app.subscription_url
  description = "The URL of the CI/CD dashboard."
}


output "feature_flags_dashboard_url" {
  value       = btp_subaccount_subscription.feature_flags_dashboard_app.subscription_url
  description = "The URL of the Feature Flags dashboard."
}

output "application_logging_dashboard_url" {
  value       = cloudfoundry_service_instance.application_logging.dashboard_url
  description = "The URL of the Feature Flags dashboard."
}

output "application_autoscaler_dashboard_url" {
  value       = cloudfoundry_service_instance.application_scaling.dashboard_url
  description = "The URL of the Application Autoscaler dashboard."
}