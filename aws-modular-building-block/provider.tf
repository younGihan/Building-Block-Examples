# Backend AWS credentials are set as environmental varialbes
# which are setup in the Building Block definition
terraform {
  backend "s3" {
    bucket = "test-tf-bucket-156c567da5092"
    key    = "tf-state"
    region = "eu-central-1"
  }
}

provider "aws" {
  region      = "eu-central-1"
  access_key = var.access_key
  secret_key = var.secret_key
}
