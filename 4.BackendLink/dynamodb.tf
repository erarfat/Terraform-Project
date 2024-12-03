provider "aws" {
  region = "us-east-1"
}

resource "aws_dynamodb_table" "tolock" {
  name = "statefilelock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID" # to create and lock the primary key
  attribute {
    name = "LockID"
    type = "S"
  }
}