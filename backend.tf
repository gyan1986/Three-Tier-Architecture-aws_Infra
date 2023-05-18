terraform {
  required_version = ">= 1.4.0"
  backend "s3" {
    bucket  = "terraform-state-gprao1986"
    key     = "project01/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}