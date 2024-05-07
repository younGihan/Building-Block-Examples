variable "enable_module_a" {
  description = "If set to true, enable module a"
  type        = bool
  default = false
}

variable "bucket_name" {
  description = "Name of the bucket"
  type        = string
  default = "test-tf-bucket-156c567da509"
}