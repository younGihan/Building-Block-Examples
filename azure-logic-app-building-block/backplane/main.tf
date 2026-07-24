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

# Gmail managed API (alternative "send email" connector). Only created when
# var.email_connector = "gmail"; the Office 365 connection above is left
# unconditional so selecting "office365" (the default) never changes its
# resource address in state.
data "azurerm_managed_api" "gmail" {
  count    = var.email_connector == "gmail" ? 1 : 0
  name     = "gmail"
  location = azurerm_resource_group.this.location
}

# As with the Office 365 connection above, Terraform can create this
# resource but Google's OAuth consent must be completed manually once, in
# the Azure Portal (Resource Groups > ${var.resource_group_name} >
# ${var.gmail_connection_name} > "Edit API connection"), by an owner of the
# Gmail account. The Logic App will fail Send-email runs until that's done.
resource "azurerm_api_connection" "gmail" {
  count               = var.email_connector == "gmail" ? 1 : 0
  name                = var.gmail_connection_name
  resource_group_name = azurerm_resource_group.this.name
  managed_api_id      = data.azurerm_managed_api.gmail[0].id
  display_name        = "Gmail - Firewall Request Emails"

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
    "$connections" = jsonencode(merge(
      {
        office365 = {
          connectionId   = azurerm_api_connection.office365.id
          connectionName = azurerm_api_connection.office365.name
          id             = data.azurerm_managed_api.office365.id
        }
      },
      var.email_connector == "gmail" ? {
        gmail = {
          connectionId   = azurerm_api_connection.gmail[0].id
          connectionName = azurerm_api_connection.gmail[0].name
          id             = data.azurerm_managed_api.gmail[0].id
        }
      } : {}
    ))
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

# Branches on the parsed "eventType" (create/delete) and sends the matching
# email. Each branch's Compose/Send actions are nested inline as JSON since
# Logic Apps embeds If-action branches directly rather than as sibling steps.
resource "azurerm_logic_app_action_custom" "handle_event" {
  name         = "Handle_Event"
  logic_app_id = azurerm_logic_app_workflow.this.id

  body = jsonencode({
    type       = "If"
    expression = "@equals(body('Parse_JSON')?['eventType'], 'delete')"
    actions = {
      Compose_Deletion_Email_Body = {
        type   = "Compose"
        inputs = local.email_body_html_delete
      }
      Send_Deletion_Email = {
        type = "ApiConnection"
        inputs = {
          host   = local.mail_connection_host
          method = "post"
          path   = local.mail_action_path
          body = merge({
            To      = "@body('Parse_JSON')?['recipient']"
            Cc      = "@body('Parse_JSON')?['cc']"
            Subject = "@body('Parse_JSON')?['subject']"
            Body    = "@{outputs('Compose_Deletion_Email_Body')}"
          }, local.mail_body_extra)
        }
        runAfter = {
          Compose_Deletion_Email_Body = ["Succeeded"]
        }
      }
    }
    else = {
      actions = {
        Compose_Creation_Email_Body = {
          type   = "Compose"
          inputs = local.email_body_html_create
        }
        Send_Creation_Email = {
          type = "ApiConnection"
          inputs = {
            host   = local.mail_connection_host
            method = "post"
            path   = local.mail_action_path
            body = merge({
              To      = "@body('Parse_JSON')?['recipient']"
              Cc      = "@body('Parse_JSON')?['cc']"
              Subject = "@body('Parse_JSON')?['subject']"
              Body    = "@{outputs('Compose_Creation_Email_Body')}"
            }, local.mail_body_extra)
          }
          runAfter = {
            Compose_Creation_Email_Body = ["Succeeded"]
          }
        }
      }
    }
    runAfter = {
      (azurerm_logic_app_action_custom.parse_json.name) = ["Succeeded"]
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
      body       = "Firewall @{if(equals(body('Parse_JSON')?['eventType'], 'delete'), 'deletion', 'creation')} request email sent to @{body('Parse_JSON')?['recipient']}."
    }
    runAfter = {
      (azurerm_logic_app_action_custom.handle_event.name) = ["Succeeded"]
    }
  })
}
