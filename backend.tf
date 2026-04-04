terraform {
  backend "s3" {
    bucket         = "angel-tfstate-lauu1zrm"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}
