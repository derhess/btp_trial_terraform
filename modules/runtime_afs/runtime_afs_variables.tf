
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
# User lists
# ------------------------------------------------------------------------------------------------------
variable "developers" {
  type        = list(string)
  description = "Defines the users who have the role collection 'application-frontend-developer' of the role 'Application_Frontend_Developer'."

  # add validation to check if admins contains a list of valid email addresses
  validation {
    condition     = length([for email in var.developers : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))]) == length(var.developers)
    error_message = "Please enter a valid email address for the 'application-frontend-developer' role."
  }
}

