terraform {

  backend "s3" {
    bucket         	   = "automobannapp"
    key              	   = "dev/resource.tfstate"
    region         	   = "us-east-2"
    encrypt        	   = true
    dynamodb_table         = "terraform-automobannlock"
  }
}