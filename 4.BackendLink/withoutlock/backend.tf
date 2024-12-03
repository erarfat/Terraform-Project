terraform {
  backend "s3" {
    bucket = "mystatefile4278"
    region = "us-east-1"
    key = "arfat"
  }
}