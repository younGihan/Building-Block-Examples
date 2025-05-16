resource "null_resource" "example" {
  triggers = {
    #map_data      = jsonencode(var.map_example)
    list_data     = jsonencode(var.list_example)
    list_object_data = jsonencode(var.list_of_objects_example)
  }
}

#output "map_output" {
#  value = var.map_example
#}

output "list_output" {
  value = var.list_example
}

output "list_of_objects_output" {
  value = var.list_of_objects_example
}
