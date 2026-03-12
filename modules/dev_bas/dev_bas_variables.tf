variable "subaccount_id" {
  description = "The subaccount ID"
  type        = string
}

# ------------------------------------------------------------------------------------------------------
# User lists
# ------------------------------------------------------------------------------------------------------
variable "bas_admins" {
  type        = list(string)
  description = "Defines the users who have the 'Business Application Studio' admin role of 'Business_Application_Studio_Administrator'."

  # add validation to check if admins contains a list of valid email addresses
  validation {
    condition     = length([for email in var.bas_admins : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))]) == length(var.bas_admins)
    error_message = "Please enter a valid email address for the 'Business Application Studio' admins."
  }
}

variable "bas_developers" {
  type        = list(string)
  description = "Defines the users who have the 'Business Application Studio' developer role of 'Business_Application_Studio_Developer'."

  # add validation to check if developers contains a list of valid email addresses
  validation {
    condition     = length([for email in var.bas_developers : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))]) == length(var.bas_developers)
    error_message = "Please enter a valid email address for the 'Business Application Studio' developers."
  }
}