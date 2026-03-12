variable "subaccount_id" {
  description = "The subaccount ID"
  type        = string
}

# ------------------------------------------------------------------------------------------------------
# User lists
# ------------------------------------------------------------------------------------------------------

variable "admins" {
  type        = list(string)
  description = "Defines the users who have the 'Build Code' admin role of 'RegistryAdmin' and 'Business_Application_Studio_Administrator'."

  # add validation to check if admins contains a list of valid email addresses
  validation {
    condition     = length([for email in var.admins : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))]) == length(var.admins)
    error_message = "Please enter a valid email address for the 'Build Code' admins."
  }
}


variable "developers" {
  type        = list(string)
  description = "Defines the users who have the 'Build Code' developer role of 'RegistryDeveloper' and 'Business_Application_Studio_Developer'."

  # add validation to check if admins contains a list of valid email addresses
  validation {
    condition     = length([for email in var.developers : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))]) == length(var.developers)
    error_message = "Please enter a valid email address for the 'Build Code' developers."
  }
}
