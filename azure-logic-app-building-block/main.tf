locals {
  firewall_request = {
    requestedBy           = var.requested_by
    ticketNumber          = var.ticket_number
    sourceIp              = var.source_ip
    destinationIp         = var.destination_ip
    port                  = var.port
    protocol              = var.protocol
    direction             = var.direction
    businessJustification = var.business_justification
  }

  payload = jsonencode({
    eventType       = "create"
    recipient       = var.recipient
    cc              = var.cc
    subject         = var.subject
    firewallRequest = local.firewall_request
  })

  delete_payload = jsonencode({
    eventType       = "delete"
    recipient       = var.recipient
    cc              = var.cc
    subject         = var.subject
    firewallRequest = local.firewall_request
  })
}

# Invokes the Logic App's HTTP trigger once. Re-running `tofu apply` with
# unchanged inputs does NOT resend the email, since the trigger is keyed to
# the payload content; change any variable (e.g. ticket_number) to fire again.
resource "terraform_data" "trigger_logic_app" {
  triggers_replace = [local.payload]

  provisioner "local-exec" {
    command = "echo \"${base64encode(local.payload)}\" | base64 --decode | curl -sS -X POST \"${var.logic_app_trigger_url}\" -H \"Content-Type: application/json\" --data-binary @- --fail"
  }
}

# Sends the deletion-request email when this building block is destroyed.
# Deliberately a *separate* resource with no triggers_replace: unlike
# `trigger_logic_app` above, it must NOT be replaced (and thus destroyed) on
# every input change, only when the building block itself is torn down.
# Destroy-time provisioners may only reference the resource's own attributes
# (via `self`), so both the URL and payload are bundled into `input` here
# instead of being read from `var.*` directly in the command.
resource "terraform_data" "notify_deletion" {
  input = {
    url     = var.logic_app_trigger_url
    payload = local.delete_payload
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo \"${base64encode(self.output.payload)}\" | base64 --decode | curl -sS -X POST \"${self.output.url}\" -H \"Content-Type: application/json\" --data-binary @- --fail"
  }
}
