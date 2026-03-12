
# ------------------------------------------------------------------------------------------------------
# Project Settings
# ------------------------------------------------------------------------------------------------------

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

variable "project_costcenter" {
  description = "Cost center of the project"
  type        = string
  default     = "12345"
  validation {
    condition     = can(regex("^[0-9]{5}$", var.project_costcenter))
    error_message = "Cost center must be a 5 digit number"
  }
}

# ------------------------------------------------------------------------------------------------------
# Subaccount Settings
# ------------------------------------------------------------------------------------------------------

variable "region" {
  type        = string
  description = "The region where the subaccount shall be created in."
  default     = "us10"
}

variable "subaccount_name" {
  type        = string
  description = "The subaccount name."
  default     = "My SAP DC mission subaccount."
}

# ------------------------------------------------------------------------------------------------------
# OTHERS
# ------------------------------------------------------------------------------------------------------

variable "cli_server_url" {
  type        = string
  description = "The BTP CLI server URL."
  default     = "https://cli.btp.cloud.sap"
}

variable "custom_idp" {
  type        = string
  description = "The custom identity provider for the subaccount."
  default     = ""
}


# ------------------------------------------------------------------------------------------------------
# User lists
# ------------------------------------------------------------------------------------------------------
variable "subaccount_admins" {
  type        = list(string)
  description = "Defines the users who are added to subaccount as administrators."

  # add validation to check if admins contains a list of valid email addresses
  validation {
    condition     = length([for email in var.subaccount_admins : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))]) == length(var.subaccount_admins)
    error_message = "Please enter a valid email address for the subaccount admins."
  }
}

variable "subaccount_emergency_admins" {
  type        = list(string)
  description = "Defines the users who are added to subaccount as emergency administrators."

  # add validation to check if admins contains a list of valid email addresses
  validation {
    condition     = length([for email in var.subaccount_emergency_admins : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))]) == length(var.subaccount_emergency_admins)
    error_message = "Please enter a valid email address for the subaccount emergency administrators."
  }
}

variable "subaccount_developers" {
  type        = list(string)
  description = "Defines the users who are added to subaccount as developers."

  # add validation to check if admins contains a list of valid email addresses
  validation {
    condition     = length([for email in var.subaccount_developers : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))]) == length(var.subaccount_developers)
    error_message = "Please enter a valid email address for the subaccount developers."
  }
}