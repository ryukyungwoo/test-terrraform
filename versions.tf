terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-3"

  default_tags {
    tags = {
      Environment = "dev"
      ManagedBy = "terraform"
    }
  }
}