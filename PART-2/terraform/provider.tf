terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.84.0"
    }
  }
  backend "s3" {
    bucket = "s3-tutorial-part2-policies"
    key    = "expense-infra"
    region = "us-east-1"

  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}