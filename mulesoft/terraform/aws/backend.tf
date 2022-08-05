terraform {
  backend "s3" {
    bucket = "tf-code-backend-state-bucket"
    region = "us-east-2"
    key    = "terraform-tfstate/mulesoft"
  }
}