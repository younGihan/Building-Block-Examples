# Provider Variable
## Assume IAM role provider
variable "assume_aws_role_name" {
  description = "AWS IAM Role name which the will be assumed to access the target AWS Account"
  type        = string
  default     = "building-block-access-role"
}

variable "external_id" {
  description = "IAM Role extneral ID which is used for the trust relationship"
  type        = string
}
variable "session_name" {
  description = "AWS Provider Session Name"
  type        = string
}

## IAM User provider
# variable "access_key" {
#   description = "Access Key for Provider"
#   type        = string
# }

# variable "secret_key" {
#   description = "Secret Key for Provider"
#   type        = string
# }

# varialble and configuration
variable "target_aws_account_id" {
  description = "Target AWS Account ID where the service will be rolled out"
  type        = string
}
variable "bucket_name" {
  description = "Name of the bucket"
  type        = string
  default     = "test-tf-bucket-1231234-2"
}
variable "UUID" {
  description = "uuid"
  type        = string
}


# modules
variable "enable_hub" {
  description = "If set to true, enable module a"
  type        = bool
  default     = true
}

variable "enable_module_a" {
  description = "If set to true, enable module a"
  type        = bool
  default     = false
}

variable "enable_module_b" {
  description = "If set to true, enable module b"
  type        = bool
  default     = false
}

