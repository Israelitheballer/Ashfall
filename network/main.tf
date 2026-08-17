terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "ashfall-terraform-state"
    key            = "network/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ashfall-terraform-locks"
    encrypt        = true
    profile        = "ashfall"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "ashfall"
}


