resource "aws_dynamodb_table" "Image_to_label" {
  name           = "Image_to_label"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "filename"
  #range_key      = "GameTitle"

  attribute {
    name = "filename"
    type = "S"
  }

  tags = {
    Name        = "Image_to_label"
    Environment = "production"
  }
}