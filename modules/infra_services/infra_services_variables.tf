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
# Cloud Foundry Runtime - specific variables
# ------------------------------------------------------------------------------------------------------
# Cloud Foundry Runtime
variable "cf_space_id" {
  description = "The Cloud Foundry space ID"
  type        = string
}

# ------------------------------------------------------------------------------------------------------
# User lists
# ------------------------------------------------------------------------------------------------------
variable "admins" {
  type        = list(string)
  description = "Defines the users who have the 'Business Application Studio' admin role of 'Business_Application_Studio_Administrator'."

  # add validation to check if admins contains a list of valid email addresses
  validation {
    condition     = length([for email in var.admins : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))]) == length(var.admins)
    error_message = "Please enter a valid email address for the 'Business Application Studio' admins."
  }
}


variable "developers" {
  type        = list(string)
  description = "Defines the users who have the 'developer' role of DEV services."

  # add validation to check if developers contains a list of valid email addresses
  validation {
    condition     = length([for email in var.developers : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))]) == length(var.developers)
    error_message = "Please enter a valid email address for the 'developer' users."
  }
}
