# CI/CD Infrastructure with Terraform

This directory contains the Terraform configuration for setting up a complete CI/CD infrastructure on AWS. The infrastructure is designed to be scalable, secure, and follows AWS best practices.

## Architecture Overview

The infrastructure consists of the following main components:

### 1. Networking (VPC Module)
- VPC with public and private subnets across multiple Availability Zones
- Internet Gateway for public subnet internet access
- NAT Gateway for private subnet outbound connectivity
- Route tables for traffic management
- Security groups for granular traffic control

### 2. CI/CD Tools (CICD Module)
- Jenkins server for continuous integration and deployment
- Nexus Repository Manager for artifact storage and dependency management
- S3 buckets for artifact storage with versioning and encryption
- IAM roles and security groups for each service with least-privilege access

### 3. Kubernetes Platform (EKS Module)
- Amazon EKS cluster for container orchestration
- Managed node groups with configurable instance types 
- Support for both On-Demand and Spot instances for cost optimization
- Private networking with secure VPC integration
- IAM roles and security groups for cluster and nodes

## Prerequisites

Before deploying this infrastructure, you need:

1. AWS CLI installed and configured with appropriate permissions
2. Terraform v1.0.0+ installed
3. A valid SSH key pair for secure server access
4. An understanding of AWS networking concepts
5. Sufficient AWS quotas for the services being deployed

## Deployment Instructions

### Step 1: Set Up Terraform State Management

Terraform state must be properly managed to allow team collaboration and state locking. Run the provided setup script:

```bash
# Make the setup script executable
chmod +x terraform-setup.sh

# Run the setup script to create S3 bucket and DynamoDB table
./terraform-setup.sh
```

The script performs the following actions:
- Creates an S3 bucket for state storage with encryption and versioning
- Configures bucket to block all public access
- Creates a DynamoDB table for state locking
- Configures backend settings for the project

### Step 2: Configure Variables

1. Create a `terraform.tfvars` file based on the example:

```bash
# Create your variables file
cp terraform.tfvars.example terraform.tfvars

# Edit the file with your settings
nano terraform.tfvars
```

2. Configure the required and optional variables:

```hcl
# Required Variables
aws_region         = "us-east-1"
environment        = "dev"
project_name       = "boardgame-cicd"
vpc_cidr           = "10.0.0.0/16"
key_name           = "boardgame-cicd-key"  # Your existing SSH key name in AWS

# Optional - Set to override defaults
availability_zones     = ["us-east-1a", "us-east-1b"]
instance_type          = "t3.medium"
cluster_version        = "1.24"
node_instance_types    = ["t3.medium"]
admin_cidr             = "10.0.0.0/8"  # Restrict this to your IP/network
artifacts_bucket_name  = "your-artifacts-bucket-name"
```

### Step 3: Initialize Terraform

Initialize Terraform to download providers and modules:

```bash
terraform init
```

### Step 4: Review the Execution Plan

Generate and review the execution plan:

```bash
terraform plan
```

### Step 5: Apply the Configuration

Apply the Terraform configuration to build the infrastructure:

```bash
terraform apply
```

The deployment will take approximately 15-20 minutes. The process creates:
1. VPC and networking components (5-7 minutes)
2. IAM roles and security groups (1-2 minutes)
3. CI/CD servers (5-7 minutes)
4. EKS cluster and node groups (10-15 minutes)

### Step 6: Accessing Your Infrastructure

After successful deployment, access your infrastructure components:

```bash
# Get the Jenkins server's public IP address
JENKINS_IP=$(terraform output -raw jenkins_public_ip)
echo "Jenkins server available at: http://${JENKINS_IP}:8080"

# Get the Nexus server's public IP address
NEXUS_IP=$(terraform output -raw nexus_public_ip)
echo "Nexus server available at: http://${NEXUS_IP}:8081"

# Configure kubectl to access your EKS cluster
aws eks update-kubeconfig --region $(terraform output -raw region) --name $(terraform output -raw cluster_name)

# Verify cluster connectivity
kubectl get nodes
```

### Step 7: Generate Ansible Inventory

Run the provided script to generate an Ansible inventory file based on the deployed infrastructure:

```bash
./run-ci-cd.sh
```

This creates an Ansible inventory file in the `../Ansible/` directory with the IP addresses of the Jenkins and Nexus servers.

## Infrastructure Management

### Updating Infrastructure

To update your infrastructure:

```bash
# Pull latest changes from version control
git pull

# Review the changes that would be applied
terraform plan

# Apply the changes
terraform apply
```

### Destroying Infrastructure

To tear down the infrastructure when no longer needed:

```bash
terraform destroy
```

⚠️ **Warning**: This will permanently delete all resources created by this Terraform configuration, including data in S3 buckets and databases.

## Troubleshooting Common Issues

- **Insufficient IAM permissions**: Ensure your AWS user has administrator privileges or the appropriate IAM permissions.
- **Resource limits**: Check if you've hit AWS service limits for resources like VPCs or EC2 instances.
- **SSH key not found**: Ensure the specified SSH key pair exists in the AWS region you're deploying to.
- **Networking issues**: Check security group rules and network ACLs if you can't connect to instances.

## Next Steps

Once your infrastructure is successfully deployed, proceed to the [Ansible directory](../Ansible/) to configure the servers and install the required software for your CI/CD pipeline.