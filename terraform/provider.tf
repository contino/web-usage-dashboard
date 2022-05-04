terraform {
  required_providers {
    aws = {
      version = "~> 4.9.0"
      source = "hashicorp/aws"
    }
  }

  required_version = ">= 1.1.0"

}

provider "aws" {
  region                      = "eu-west-2"
}