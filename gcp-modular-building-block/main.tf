module "hub" {
  bucket_name = "${var.bucket_name}"
  source = "./hub"

}

module "module-a" {
  count  = var.enable_module_a ? 1 : 0
  bucket_name = "${var.bucket_name}"
  source = "./module-a"

  depends_on = [module.hub]
}
