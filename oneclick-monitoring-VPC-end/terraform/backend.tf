terraform {
  backend "s3" {
    bucket         = "oneclick-terraform.tf-bucket-vpc-end"
    key            = "oneclick-monitoring/terraform.tfstate-vpc-end"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-locks-vpc-end"
  }
}
