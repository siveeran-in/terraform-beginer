terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.6.1"
    }
  }
}

provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIATPWBFSSPLGHKKPOA"
  secret_key = "rDEfZPMhF0osu2bF3iWe52QCniOVUrUKeS7L TRb"
}