locals {
  payload = jsonencode({
    recipient = var.recipient
    cc        = var.cc
    subject   = var.subject
    firewallRequest = {
      requestedBy           = var.requested_by
      ticketNumber          = var.ticket_number
      sourceIp              = var.source_ip
      destinationIp         = var.destination_ip
      port                  = var.port
      protocol              = var.protocol
      direction             = var.direction
      businessJustification = var.business_justification
    }
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
