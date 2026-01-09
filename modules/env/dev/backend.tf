terraform {
  backend "s3" {
    bucket         = "capstone-tf-state-391a42cb"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "capstone-terraform-locks"
    encrypt        = true
  }
}
