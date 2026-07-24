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

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default = {
    purpose = "firewall-request-email-workflow"
  }
}
