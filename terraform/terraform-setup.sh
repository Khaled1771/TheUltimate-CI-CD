#!/bin/bash
# This script creates the required S3 bucket and DynamoDB table for Terraform state management

# Create S3 bucket for state storage
aws s3 mb s3://enterprise-cicd-terraform-state --region us-east-1

# Enable versioning on the bucket
aws s3api put-bucket-versioning \
  --bucket enterprise-cicd-terraform-state \
  --versioning-configuration Status=Enabled

# Enable encryption on the bucket
aws s3api put-bucket-encryption \
  --bucket enterprise-cicd-terraform-state \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

# Block public access to the bucket
aws s3api put-public-access-block \
  --bucket enterprise-cicd-terraform-state \
  --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name enterprise-cicd-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1

echo "Terraform state management resources created successfully!"
echo "Run 'terraform init' to initialize your Terraform configuration."