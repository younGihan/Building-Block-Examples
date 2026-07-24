locals {
  # JSON schema for the HTTP trigger's expected request body. Used both to
  # validate the incoming call (trigger schema) and to re-parse it explicitly
  # (Parse JSON action) so downstream expressions get typed properties.
  request_schema = {
    type = "object"
    properties = {
      recipient = { type = "string" }
      cc        = { type = "string" }
      subject   = { type = "string" }
      firewallRequest = {
        type = "object"
        properties = {
          requestedBy           = { type = "string" }
          ticketNumber          = { type = "string" }
          sourceIp              = { type = "string" }
          destinationIp         = { type = "string" }
          port                  = { type = "string" }
          protocol              = { type = "string" }
          direction             = { type = "string" }
          businessJustification = { type = "string" }
        }
        required = [
          "requestedBy",
          "sourceIp",
          "destinationIp",
          "port",
          "protocol",
          "direction",
          "businessJustification",
        ]
      }
    }
    required = ["recipient", "subject", "firewallRequest"]
  }

  # HTML body for the outgoing email, addressed to the IT team, populated
  # with the parsed firewall request parameters via Logic App expressions.
  email_body_html = <<-HTML
    <p>Dear IT Team,</p>
    <p>A new firewall change request has been submitted via the automated request workflow. Details below:</p>
    <table border="1" cellpadding="6" cellspacing="0" style="border-collapse:collapse;">
      <tr><td><strong>Requested By</strong></td><td>@{body('Parse_JSON')?['firewallRequest']?['requestedBy']}</td></tr>
      <tr><td><strong>Ticket Number</strong></td><td>@{body('Parse_JSON')?['firewallRequest']?['ticketNumber']}</td></tr>
      <tr><td><strong>Source IP</strong></td><td>@{body('Parse_JSON')?['firewallRequest']?['sourceIp']}</td></tr>
      <tr><td><strong>Destination IP</strong></td><td>@{body('Parse_JSON')?['firewallRequest']?['destinationIp']}</td></tr>
      <tr><td><strong>Port</strong></td><td>@{body('Parse_JSON')?['firewallRequest']?['port']}</td></tr>
      <tr><td><strong>Protocol</strong></td><td>@{body('Parse_JSON')?['firewallRequest']?['protocol']}</td></tr>
      <tr><td><strong>Direction</strong></td><td>@{body('Parse_JSON')?['firewallRequest']?['direction']}</td></tr>
      <tr><td><strong>Business Justification</strong></td><td>@{body('Parse_JSON')?['firewallRequest']?['businessJustification']}</td></tr>
    </table>
    <p>Please review and action this request at your earliest convenience.</p>
    <p>Kind regards,<br/>Automated Firewall Request Workflow</p>
  HTML
}
