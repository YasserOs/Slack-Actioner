terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
  
  backend "s3" {
    bucket         	   = "yosm-terraform-tfstate"
    key              	   = "state/terraform.tfstate"
    region         	   = "us-east-2"
    encrypt        	   = true
    dynamodb_table = "terraform-tfstate-lock"
  }
}

provider "aws" {
  region  = "us-east-2"
}
