terraform {
  backend "s3" {
    bucket         = "oneclick-terraform-tf-bucket-nat"
    key            = "oneclick-monitoring/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-locks-nat"
  }
}
