output "idp_origin" {
  value       = local.custom_idp_origin
  description = "The Custom Identity Provider origin"
}

output "idp_tenant_domain" {
  value       = local.custom_idp_tenant_url
  description = "The SAP Cloud Identity Service Tenant URL"
}

output "idp_tenant_admin_url" {
  value       = btp_subaccount_subscription.sap_identity.subscription_url
  description = "The SAP Cloud Identity Service Tenant URL"
}