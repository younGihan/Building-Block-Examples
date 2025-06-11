resource "null_resource" "example" {
  triggers = {
    example_string   = var.example_string
    buildingBlockRun = var.buildingBlockRun
  }
}