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
    bucket         = "board-game-terraform-state-20250427-170644"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "board-game-terraform-locks"
    encrypt        = true
  }
}