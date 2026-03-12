variable "globalaccount" {
  description = "The global account ID"
  type        = string
}

variable "cli_server_url" {
  description = "The CLI server URL"
  type        = string
}

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

# ABAP Runtime
variable "abap_admin_email" {
  type        = string
  description = "Email of the ABAP Administrator."
  default     = ""
}

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

# Services
variable "build_code_admins" {
  type        = list(string)
  description = "Defines the users who have the 'Build Code' admin role of 'RegistryAdmin' and 'Business_Application_Studio_Administrator'."

  # add validation to check if admins contains a list of valid email addresses
  validation {
    condition     = length([for email in var.build_code_admins : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))]) == length(var.build_code_admins)
    error_message = "Please enter a valid email address for the 'Build Code' admins."
  }
}


variable "build_code_developers" {
  type        = list(string)
  description = "Defines the users who have the 'Build Code' developer role of 'RegistryDeveloper' and 'Business_Application_Studio_Developer'."

  # add validation to check if admins contains a list of valid email addresses
  validation {
    condition     = length([for email in var.build_code_developers : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))]) == length(var.build_code_developers)
    error_message = "Please enter a valid email address for the 'Build Code' developers."
  }
}




# Process Automation
variable "process_automation_admins" {
  type        = list(string)
  description = "Defines the users who have the 'ProcessAutomationAdmin' role."

  # add validation to check if admins contains a list of valid email addresses
  validation {
    condition     = length([for email in var.process_automation_admins : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))]) == length(var.process_automation_admins)
    error_message = "Please enter a valid email address for the 'Process Automation' admins."
  }
}

variable "process_automation_delegates" {
  type        = list(string)
  description = "Defines the users who have the 'ProcessAutomationDelegate' role."

  # add validation to check if admins contains a list of valid email addresses
  validation {
    condition     = length([for email in var.process_automation_delegates : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))]) == length(var.process_automation_delegates)
    error_message = "Please enter a valid email address for the 'Process Automation' delegates."
  }
}

variable "process_automation_developers" {
  type        = list(string)
  description = "Defines the users who have the 'ProcessAutomationDeveloper' role."

  # add validation to check if admins contains a list of valid email addresses
  validation {
    condition     = length([for email in var.process_automation_developers : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))]) == length(var.process_automation_developers)
    error_message = "Please enter a valid email address for the 'Process Automation' developers."
  }
}

variable "process_automation_experts" {
  type        = list(string)
  description = "Defines the users who have the 'ProcessAutomationExpert' role."

  # add validation to check if admins contains a list of valid email addresses
  validation {
    condition     = length([for email in var.process_automation_experts : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))]) == length(var.process_automation_experts)
    error_message = "Please enter a valid email address for the 'Process Automation' experts."
  }
}

variable "process_automation_participants" {
  type        = list(string)
  description = "Defines the users who have the 'ProcessAutomationParticipant' role."

  # add validation to check if admins contains a list of valid email addresses
  validation {
    condition     = length([for email in var.process_automation_participants : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))]) == length(var.process_automation_participants)
    error_message = "Please enter a valid email address for the 'Process Automation' participants."
  }
}





variable "cicd_admins" {
  type        = list(string)
  description = "Defines the colleagues who are administrators for the CI/CD service."
  default     = []
  # add validation to check if admins contains a list of valid email addresses
  validation {
    condition     = length([for email in var.cicd_admins : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))]) == length(var.cicd_admins)
    error_message = "Please enter a valid email address."
  }
}

variable "cicd_developers" {
  type        = list(string)
  description = "Defines the colleagues who are developers for the CI/CD service."
  default     = []
  # add validation to check if admins contains a list of valid email addresses
  validation {
    condition     = length([for email in var.cicd_developers : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))]) == length(var.cicd_developers)
    error_message = "Please enter a valid email address."
  }
}

