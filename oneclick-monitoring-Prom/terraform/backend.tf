terraform {
  backend "s3" {
    bucket         = "oneclick-monitoring-bucket-rahul"
    key            = "oneclick-monitoring/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-locks-monitoring"
  }
}
