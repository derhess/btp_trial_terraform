output "mobile_service_dashboard_url" {
  value       = cloudfoundry_service_instance.mobile_services.dashboard_url
  description = "The URL of the SAP Business Application Studio dashboard."
}