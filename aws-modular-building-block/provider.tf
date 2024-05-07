# Backend AWS credentials are set as environmental varialbes
# which are setup in the Building Block definition
terraform {
  backend "s3" {
    bucket = "test-tf-bucket-156c567da5092"
    key    = "tf-state"
    region = "eu-central-1"
  }
}

# Provider with AWS IAM User
# provider "aws" {
#   region      = "eu-central-1"
#   access_key = var.access_key
#   secret_key = var.secret_key
# }

# Provider with Assume AWS IAM Role
# In this case the IAM User set in the environment will try to assume the specified role
# Therefore the same IAM user as for the Backend is used to roll out the serivce
# role_arn can also be set as environment variable AWS_ROLE_ARN
provider "aws" {
  assume_role {
    role_arn     = "arn:aws:iam::${var.target_aws_account_id}:role/${var.assume_aws_role_name}"
    session_name = var.session_name
    external_id  = var.external_id
  }
}