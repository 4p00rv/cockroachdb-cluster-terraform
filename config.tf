terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  backend "s3" {
    bucket = "4p00rv-test"
    key = "terraform/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

provider "aws" {
  region  = "ap-southeast-1"
}

