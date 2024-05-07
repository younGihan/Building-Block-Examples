module "hub" {
  count  = var.enable_hub ? 1 : 0
  bucket_name = "${var.bucket_name}"
  source = "./hub"
}

module "module-a" {
  count  = var.enable_module_a ? 1 : 0
  bucket_name = "${var.bucket_name}"
  source = "./module-a"
}

module "module-b" {
  count  = var.enable_module_b ? 1 : 0
  bucket_name = "${var.bucket_name}"
  source = "./module-b"
}
