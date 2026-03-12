
variable "subaccount_id" {
  description = "The subaccount ID"
  type        = string
}

# ------------------------------------------------------------------------------------------------------
# Identity Authentication and Authorization
# ------------------------------------------------------------------------------------------------------
variable "custom_idp" {
  description = "Custom Identity Provider"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------------------------------
# Runtime Environments
# ------------------------------------------------------------------------------------------------------
# Cloud Foundry Runtime
variable "cf_space_id" {
  description = "The Cloud Foundry space ID"
  type        = string
}

# ------------------------------------------------------------------------------------------------------
# User lists
# ------------------------------------------------------------------------------------------------------

# ABAP Runtime
variable "abap_admin_email" {
  type        = string
  description = "Email of the ABAP Administrator."
}