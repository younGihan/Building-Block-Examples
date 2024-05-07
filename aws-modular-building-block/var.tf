variable "enable_hub" {
  description = "If set to true, enable module a"
  type        = bool
  default = false
}

variable "enable_module_a" {
  description = "If set to true, enable module a"
  type        = bool
  default = false
}

variable "enable_module_b" {
  description = "If set to true, enable module b"
  type        = bool
  default = false
}

variable "bucket_name" {
  description = "Name of the bucket"
  type        = string
  default = "test-tf-bucket-1231234-2"
}

variable "access_key" {
  description = "Access Key for Provider"
  type        = string
}

variable "secret_key" {
  description = "Secret Key for Provider"
  type        = string
}

variable "UUID" {
  description = "uuid"
  type        = string
}