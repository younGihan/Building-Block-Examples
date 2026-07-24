output "payload_sent" {
  description = "The JSON payload sent to the Logic App trigger."
  value       = local.payload
}

output "delete_payload" {
  description = "The JSON payload that will be sent to the Logic App trigger when this building block is destroyed."
  value       = local.delete_payload
}
