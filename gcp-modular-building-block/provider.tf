#priot to tf execution
# gcloud auth application-default login 
provider "google" {
  project     = "meshdelivery-yhk-playgr-2aj"
  region      = "europe-west1"
}

terraform {
  backend "local" {
    path = "backend/terraform.tfstate"
  }
}
