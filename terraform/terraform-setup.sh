#!/bin/bash
# This script creates the required S3 bucket and DynamoDB table for Terraform state management
# and generates the EC2 key pair for SSH access

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

# Create EC2 key pair for SSH access
KEY_NAME="enterprise-cicd-key"
KEY_FILE="${KEY_NAME}.pem"

# Check if key already exists
if aws ec2 describe-key-pairs --key-names ${KEY_NAME} 2>/dev/null ; then
  echo "Key pair ${KEY_NAME} already exists. Skipping key creation."
else
  echo "Creating new key pair: ${KEY_NAME}"
  aws ec2 create-key-pair \
    --key-name ${KEY_NAME} \
    --query 'KeyMaterial' \
    --output text > ${KEY_FILE}
  
  # Set proper permissions for the key file
  chmod 400 ${KEY_FILE}
  echo "EC2 key pair created and saved to ${KEY_FILE}"
fi

echo "Terraform state management resources created successfully!"
echo "Run 'terraform init' to initialize your Terraform configuration."
