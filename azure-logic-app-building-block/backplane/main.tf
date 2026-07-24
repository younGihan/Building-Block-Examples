resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Office 365 Outlook managed API (provides the "send email" connector operation).
data "azurerm_managed_api" "office365" {
  name     = "office365"
  location = azurerm_resource_group.this.location
}

# API connection instance. NOTE: Terraform can create this resource, but Microsoft
# does not expose a non-interactive way to complete the OAuth consent for it. After
# `tofu apply`, an owner of the mailbox must open this connection in the Azure Portal
# (Resource Groups > ${var.resource_group_name} > ${var.office365_connection_name} > "Edit API connection")
# and sign in once to authorize it. The Logic App will fail Send-email runs until that's done.
resource "azurerm_api_connection" "office365" {
  name                = var.office365_connection_name
  resource_group_name = azurerm_resource_group.this.name
  managed_api_id      = data.azurerm_managed_api.office365.id
  display_name        = "Office 365 Outlook - Firewall Request Emails"

  lifecycle {
    ignore_changes = [parameter_values]
  }
}

resource "azurerm_logic_app_workflow" "this" {
  name                = var.logic_app_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags

  workflow_parameters = {
    "$connections" = jsonencode({
      defaultValue = {}
      type         = "Object"
    })
  }

  parameters = {
    "$connections" = jsonencode({
      office365 = {
        connectionId   = azurerm_api_connection.office365.id
        connectionName = azurerm_api_connection.office365.name
        id             = data.azurerm_managed_api.office365.id
      }
    })
  }
}

resource "azurerm_logic_app_trigger_http_request" "this" {
  name         = "manual_http_request"
  logic_app_id = azurerm_logic_app_workflow.this.id
  schema       = jsonencode(local.request_schema)
}

resource "azurerm_logic_app_action_custom" "parse_json" {
  name         = "Parse_JSON"
  logic_app_id = azurerm_logic_app_workflow.this.id

  body = jsonencode({
    type = "ParseJson"
    inputs = {
      content = "@triggerBody()"
      schema  = local.request_schema
    }
  })
}

resource "azurerm_logic_app_action_custom" "compose_email_body" {
  name         = "Compose_Email_Body"
  logic_app_id = azurerm_logic_app_workflow.this.id

  body = jsonencode({
    type   = "Compose"
    inputs = local.email_body_html
    runAfter = {
      (azurerm_logic_app_action_custom.parse_json.name) = ["Succeeded"]
    }
  })
}

resource "azurerm_logic_app_action_custom" "send_email" {
  name         = "Send_an_email"
  logic_app_id = azurerm_logic_app_workflow.this.id

  body = jsonencode({
    type = "ApiConnection"
    inputs = {
      host = {
        connection = {
          name = "@parameters('$connections')['office365']['connectionId']"
        }
      }
      method = "post"
      path   = "/v2/Mail"
      body = {
        To      = "@body('Parse_JSON')?['recipient']"
        Cc      = "@body('Parse_JSON')?['cc']"
        Subject = "@body('Parse_JSON')?['subject']"
        Body    = "@{outputs('Compose_Email_Body')}"
        IsHtml  = true
      }
    }
    runAfter = {
      (azurerm_logic_app_action_custom.compose_email_body.name) = ["Succeeded"]
    }
  })
}

resource "azurerm_logic_app_action_custom" "response" {
  name         = "Response"
  logic_app_id = azurerm_logic_app_workflow.this.id

  body = jsonencode({
    type = "Response"
    kind = "Http"
    inputs = {
      statusCode = 200
      body       = "Firewall request email sent to @{body('Parse_JSON')?['recipient']}."
    }
    runAfter = {
      (azurerm_logic_app_action_custom.send_email.name) = ["Succeeded"]
    }
  })
}
