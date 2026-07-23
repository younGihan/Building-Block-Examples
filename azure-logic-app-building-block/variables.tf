variable "logic_app_trigger_url" {
  description = "Callable HTTPS URL (including the SAS signature) for the firewall-request Logic App's HTTP trigger. Get it from the parent module's `get_trigger_callback_url_command` output."
  type        = string
  sensitive   = true
}

variable "recipient" {
  description = "Primary email recipient, e.g. the IT team's mailbox or distribution list."
  type        = string
}

variable "cc" {
  description = "Optional CC address(es)."
  type        = string
  default     = ""
}

variable "subject" {
  description = "Email subject line."
  type        = string
}

variable "requested_by" {
  description = "Name/email of the person requesting the firewall change."
  type        = string
}

variable "ticket_number" {
  description = "Optional ticket/reference number."
  type        = string
  default     = ""
}

variable "source_ip" {
  description = "Source IP or CIDR range for the firewall rule."
  type        = string
}

variable "destination_ip" {
  description = "Destination IP or CIDR range for the firewall rule."
  type        = string
}

variable "port" {
  description = "Port or port range for the firewall rule."
  type        = string
}

variable "protocol" {
  description = "Protocol for the firewall rule, e.g. TCP or UDP."
  type        = string
}

variable "direction" {
  description = "Traffic direction, e.g. Inbound or Outbound."
  type        = string
}

variable "business_justification" {
  description = "Business justification for the firewall change."
  type        = string
}
