variable "subaccount_id" {
  description = "The subaccount ID"
  type        = string
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
# User lists
# ------------------------------------------------------------------------------------------------------

variable "launchpad_admins" {
  type        = list(string)
  description = "Defines the users who have the role of 'Launchpad_Admin'."

  # add validation to check if admins contains a list of valid email addresses
  validation {
    condition     = length([for email in var.launchpad_admins : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))]) == length(var.launchpad_admins)
    error_message = "Please enter a valid email address for the launchpad admins."
  }
}

# ------------------------------------------------------------------------------------------------------
# Custom Identity Origin of SAP BTP Subaccount Trust Configuration
# ------------------------------------------------------------------------------------------------------

variable "custom_idp_origin" {
  
  type        = string
  description = "The custom identity provider origin for the SAP BTP subaccount trust configuration. This is required to assign the 'Launchpad_Admin' role collection to users of a custom identity provider. The value must match the origin defined in the trust configuration, e.g. 'custom' or 'myidentityprovider'."
  default     = "sap.custom"
  
  validation {
    condition     = can(regex("^([a-z]{3,6}.[a-z]{3,6})+$", var.custom_idp_origin))
    error_message = "Invalid value for service_plan__sap_launchpad. Only 'standard' is allowed."
  }
}


# ------------------------------------------------------------------------------------------------------
# app subscription plans
# ------------------------------------------------------------------------------------------------------
variable "service_plan__sap_launchpad" {
  type        = string
  description = "The plan for app subscription 'SAP Build Work Zone, standard edition' with technical name 'SAPLaunchpad'"
  default     = "standard"
  validation {
    condition     = contains(["standard"], var.service_plan__sap_launchpad)
    error_message = "Invalid value for service_plan__sap_launchpad. Only 'standard' is allowed."
  }
}