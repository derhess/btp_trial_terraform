
variable "subaccount_id" {
  description = "The subaccount ID"
  type        = string
}

variable "subaccount_region" {
  description = "The subaccount region"
  type        = string
  default     = "us10"
}


variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "Project ABC"
}

variable "project_stage" {
  description = "Stage of the project"
  type        = string
  default     = "DEV"
  validation {
    condition     = contains(["DEV", "TEST", "PROD"], var.project_stage)
    error_message = "Stage must be one of DEV, TEST or PROD"
  }
}


# ------------------------------------------------------------------------------------------------------
# Identity Authentication and Authorization
# ------------------------------------------------------------------------------------------------------
variable "custom_idp" {
  description = "Custom Identity Provider"
  type        = string
  default     = "sap.custom"
}
# ------------------------------------------------------------------------------------------------------
# Runtime Environments
# ------------------------------------------------------------------------------------------------------
# Cloud Foundry Runtime
variable "cf_landscape_label" {
  description = "The Cloud Foundry landscape label"
  type        = string
  default     = "exx-dev"
}


# ------------------------------------------------------------------------------------------------------
# User lists
# ------------------------------------------------------------------------------------------------------

# Cloud Foundry Runtime
variable "cf_org_managers" {
  type        = list(string)
  description = "List of managers for the Cloud Foundry org."
  default     = []
}

variable "cf_space_managers" {
  type        = list(string)
  description = "List of managers for the Cloud Foundry space."
  default     = []
}

variable "cf_space_developers" {
  type        = list(string)
  description = "List of developers for the Cloud Foundry space."
  default     = []
}

variable "cf_org_users" {
  type        = list(string)
  description = "List of users for the Cloud Foundry org."
  default     = []
}
