output "subaccount_id" {
  value       =  btp_subaccount.project_subaccount.id
  description = "The SAP BTP subaccount ID"
}

output "subaccount_url" {
  value       = "https://account.hanatrial.ondemand.com/trial/#/globalaccount/${data.btp_globalaccount.this.id}/subaccount/${btp_subaccount.project_subaccount.id}"
  description = "The SAP BTP subaccount URL"
}