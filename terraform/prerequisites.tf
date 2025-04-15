terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
  
  # Use existing S3 bucket and DynamoDB table for state management
  backend "s3" {
    bucket         = "enterprise-cicd-terraform-state"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "enterprise-cicd-terraform-locks"
    encrypt        = true
  }
}