terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "cto-in-my-pocket-launch-engine"
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = "Tech4Humanity"
      Runtime     = "launch-engine"
    }
  }
}
