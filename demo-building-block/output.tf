output "rendered_map" {
  value       = null_resource.example.triggers.map_data
  description = "Die als JSON kodierte Map."
}

output "rendered_list" {
  value       = null_resource.example.triggers.list_data
  description = "Die als JSON kodierte Liste."
}

output "rendered_list_of_objects" {
  value       = null_resource.example.triggers.list_object_data
  description = "Die als JSON kodierte Liste von Objekten."
}