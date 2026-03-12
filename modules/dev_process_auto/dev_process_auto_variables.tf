
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
  default     = "sap.custom"
}

# ------------------------------------------------------------------------------------------------------
# User lists
# ------------------------------------------------------------------------------------------------------

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


