locals {
  # Wiring for the "send mail" actions, selected via var.email_connector.
  # Defaults ("office365") reproduce exactly what was previously hardcoded,
  # so existing deployments see no diff when the variable is left unset.
  #
  # Both connectors expose a "Send email (V2)" operation named SendEmailV2
  # with matching To/Cc/Subject/Body parameters, which is why the same
  # path/method works for both; Gmail's Body parameter is already
  # HTML-typed, so unlike Office 365 it takes no separate IsHtml flag.
  # Verify against the Logic App Designer's "code view" after connecting
  # Gmail for the first time, in case Microsoft's swagger differs.
  mail_connection_host = {
    connection = {
      name = "@parameters('$connections')['${var.email_connector}']['connectionId']"
    }
  }
  mail_action_path = "/v2/Mail"
  mail_body_extra  = var.email_connector == "gmail" ? {} : { IsHtml = true }

  # JSON schema for the HTTP trigger's expected request body. Used both to
  # validate the incoming call (trigger schema) and to re-parse it explicitly
  # (Parse JSON action) so downstream expressions get typed properties.
  request_schema = {
    type = "object"
    properties = {
      eventType = { type = "string", enum = ["create", "delete"] }
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
    required = ["eventType", "recipient", "subject", "firewallRequest"]
  }

  # Shared table of the parsed firewall request parameters, reused by both
  # the creation and deletion email bodies via Logic App expressions.
  firewall_request_table_html = <<-HTML
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
  HTML

  # HTML body for the "create" event email, addressed to the IT team.
  email_body_html_create = <<-HTML
    <p>Dear IT Team,</p>
    <p>A new firewall change request has been submitted via the automated request workflow. Details below:</p>
    ${local.firewall_request_table_html}
    <p>Please review and action this request at your earliest convenience.</p>
    <p>Kind regards,<br/>Automated Firewall Request Workflow</p>
  HTML

  # HTML body for the "delete" event email, addressed to the IT team.
  email_body_html_delete = <<-HTML
    <p>Dear IT Team,</p>
    <p>The following firewall rule is no longer needed and its removal has been requested via the automated request workflow. Details below:</p>
    ${local.firewall_request_table_html}
    <p>Please remove this rule at your earliest convenience.</p>
    <p>Kind regards,<br/>Automated Firewall Request Workflow</p>
  HTML
}
