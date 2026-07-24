output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "logic_app_name" {
  value = azurerm_logic_app_workflow.this.name
}

output "logic_app_id" {
  value = azurerm_logic_app_workflow.this.id
}

output "office365_connection_authorize_note" {
  value = "Before the workflow can send mail, authorize the API connection once: Azure Portal > Resource groups > ${azurerm_resource_group.this.name} > ${azurerm_api_connection.office365.name} > 'Edit API connection' > Authorize > Save. This one-time OAuth consent cannot be done via Terraform/OpenTofu."
}

output "get_trigger_callback_url_command" {
  description = "Azure CLI command to fetch the callable HTTPS URL (with SAS signature) for the HTTP trigger."
  value       = "az rest --method post --uri \"${azurerm_logic_app_workflow.this.id}/triggers/${azurerm_logic_app_trigger_http_request.this.name}/listCallbackUrl?api-version=2016-06-01\" --query value -o tsv"
}
