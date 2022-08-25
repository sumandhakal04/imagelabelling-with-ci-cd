provider "aws" {

  region = var.aws_region

}

terraform {
  backend "s3" {
    bucket = "state-files-imagelabeller"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}