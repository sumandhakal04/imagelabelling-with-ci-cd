variable "aws_region" {
  default = "eu-central-1"
}

variable "website_bucket_name" {
  default = "imagelabeller-ssem-2022"
}

variable "cloudwatch-log-group-upload" {
  default = "image-upload-lambda-tf"
}

variable "cloudwatch-log-group-label" {
  default = "image-labeller-lambda-tf"
}

variable "lambda-upload-name" {
  default = "S3UploadHandler"
}

variable "lambda-handler-upload" {
  default = "S3UploadHandler.labelOnS3Upload"
}

variable "lambda-label-name" {
  default = "getImagesByLabelHandler"
}

variable "lambda-handler-label" {
  default = "getImagesByLabelHandler.getImagesByLabel"
}

variable "runtime" {
  default = "python3.8"
}

variable "api-gw-name" {
  default = "image-labeller-api"
}

variable "api-gw-stage-name" {
  default = "dev"
}