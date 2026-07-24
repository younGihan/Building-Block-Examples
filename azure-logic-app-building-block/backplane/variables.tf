variable "resource_group_name" {
  description = "Name of the resource group to create for the firewall-request Logic App."
  type        = string
  default     = "rg-firewall-request-logicapp"
}

variable "location" {
  description = "Azure region to deploy into."
  type        = string
  default     = "germanywestcentral"
}

variable "logic_app_name" {
  description = "Name of the Logic App workflow."
  type        = string
  default     = "logic-firewall-request-email"
}

variable "office365_connection_name" {
  description = "Name of the Office 365 Outlook API connection resource used to send email."
  type        = string
  default     = "office365-connection"
}

variable "email_connector" {
  description = "Which managed connector the workflow uses to send email: \"office365\" (Office 365 Outlook) or \"gmail\"."
  type        = string
  default     = "office365"

  validation {
    condition     = contains(["office365", "gmail"], var.email_connector)
    error_message = "email_connector must be either \"office365\" or \"gmail\"."
  }
}

variable "gmail_connection_name" {
  description = "Name of the Gmail API connection resource used to send email. Only created when email_connector = \"gmail\"."
  type        = string
  default     = "gmail-connection"
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default = {
    purpose = "firewall-request-email-workflow"
  }
}
