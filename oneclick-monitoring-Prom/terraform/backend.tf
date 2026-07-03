terraform {
  backend "s3" {
    bucket         = "rahul-monitoring-tfstate-860217763718"
    key            = "oneclick-monitoring/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-locks-monitoring"
  }
}
