output "sap_launchpad_subscription_url" {
  value       = data.btp_subaccount_subscription.sap_launchpad_data.subscription_url
  description = "SAP Build Work Zone, standard edition subscription URL."
}