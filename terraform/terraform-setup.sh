#!/bin/bash
# This script creates the required S3 bucket and DynamoDB table for Terraform state management
# and generates the EC2 key pair for SSH access

# Variables
DATE_SUFFIX=$(date +%Y%m%d-%H%M%S)
BASE_BUCKET_NAME="board-game-terraform-state"
BUCKET_NAME="${BASE_BUCKET_NAME}-${DATE_SUFFIX}"
DYNAMODB_TABLE_NAME="board-game-terraform-locks"
KEY_NAME="board-game-key"
KEY_FILE="${KEY_NAME}.pem"
PREREQUISITES_FILE="prerequisites.tf"
REGION_NAME="us-east-1"

# Function to update prerequisites.tf with new bucket name
update_prerequisites_tf() {
    local bucket_name=$1
    sed -i "s/bucket[[:space:]]*=[[:space:]]*\".*\"/bucket = \"$bucket_name\"/" "$PREREQUISITES_FILE"
    echo "Updated $PREREQUISITES_FILE with new bucket name: $bucket_name"
}

# Check if the S3 bucket already exists
if aws s3api head-bucket --bucket ${BUCKET_NAME} 2>/dev/null; then
    echo "S3 bucket ${BUCKET_NAME} already exists. Skipping bucket creation."
else
    echo "Creating S3 bucket: ${BUCKET_NAME}"
    aws s3 mb s3://${BUCKET_NAME} --region ${REGION_NAME}

    # Enable versioning on the bucket
    aws s3api put-bucket-versioning \
        --bucket ${BUCKET_NAME} \
        --versioning-configuration Status=Enabled

    # Enable encryption on the bucket
    aws s3api put-bucket-encryption \
        --bucket ${BUCKET_NAME} \
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
        --bucket ${BUCKET_NAME} \
        --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

    # Update prerequisites.tf with the new bucket name
    update_prerequisites_tf "${BUCKET_NAME}"
fi

# Check if the DynamoDB table already exists
if aws dynamodb describe-table --table-name ${DYNAMODB_TABLE_NAME} 2>/dev/null; then
    echo "DynamoDB table ${DYNAMODB_TABLE_NAME} already exists. Skipping table creation."
else
    echo "Creating DynamoDB table: ${DYNAMODB_TABLE_NAME}"
    aws dynamodb create-table \
        --table-name ${DYNAMODB_TABLE_NAME} \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region ${REGION_NAME}
fi

# Check if the EC2 key pair already exists
if aws ec2 describe-key-pairs --key-names ${KEY_NAME} 2>/dev/null; then
  if [ -f "${KEY_FILE}" ]; then
    echo "Key pair ${KEY_NAME} already exists and local key file is present. Skipping key creation."
  else
    echo "Key pair ${KEY_NAME} exists in AWS but local file is missing. Deleting and recreating key pair."
    aws ec2 delete-key-pair --key-name ${KEY_NAME}
    
    echo "Creating new key pair: ${KEY_NAME}"
    aws ec2 create-key-pair \
      --key-name ${KEY_NAME} \
      --query 'KeyMaterial' \
      --output text > ${KEY_FILE}
      --region ${REGION_NAME}

    # Set proper permissions for the key file
    chmod 400 ${KEY_FILE}
    echo "EC2 key pair created and saved to ${KEY_FILE}"
  fi
else
  echo "Creating new key pair: ${KEY_NAME}"
  aws ec2 create-key-pair \
    --key-name ${KEY_NAME} \
    --query 'KeyMaterial' \
    --output text > ${KEY_FILE}
    --region ${REGION_NAME}
  
  # Set proper permissions for the key file
  chmod 400 ${KEY_FILE}
  echo "EC2 key pair created and saved to ${KEY_FILE}"
fi

echo "Terraform state management resources created successfully!"
echo "Run 'terraform init' to initialize your Terraform configuration."
