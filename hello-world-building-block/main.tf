resource "null_resource" "example" {
  triggers = {
    example_string   = var.example_string
    buildingBlockRun = var.meshstack_building_block_run_id
  }
}