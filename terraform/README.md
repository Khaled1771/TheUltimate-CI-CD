# Enterprise CI/CD Infrastructure

This repository contains the Terraform configuration for setting up a complete enterprise-grade CI/CD infrastructure on AWS. The infrastructure is designed to be scalable, secure, and follows AWS best practices.

## Architecture Overview

The infrastructure consists of three main components:

### 1. Networking (VPC Module)
- VPC with public and private subnets across multiple Availability Zones
- Internet Gateway for public subnet internet access
- NAT Gateway for private subnet outbound connectivity
- Route tables for traffic management
- Security groups for granular traffic control
- Network ACLs for additional security layer

### 2. CI/CD Tools (CICD Module)
- Jenkins server for continuous integration and deployment
- SonarQube server for code quality analysis and security scanning
- Nexus Repository Manager for artifact storage and dependency management
- S3 buckets for artifact storage with versioning and encryption
- IAM roles and security groups for each service with least-privilege access
- All services deployed in private subnets with controlled access through bastion or VPN

### 3. Kubernetes Platform (EKS Module)
- Amazon EKS cluster for container orchestration
- Managed node groups with configurable instance types 
- Support for both On-Demand and Spot instances for cost optimization
- Private networking with secure VPC integration
- IAM roles and security groups for cluster and nodes
- Proper dependencies to ensure correct resource creation order

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
project_name       = "enterprise-cicd"
vpc_cidr           = "10.0.0.0/16"
key_name           = "enterprise-cicd-key"

# Optional - Set to override defaults
availability_zones     = ["us-east-1a", "us-east-1b", "us-east-1c"]
instance_type          = "t3.medium"
cluster_version        = "1.32"
node_instance_types    = ["t3.small"]
admin_cidr             = "10.0.0.0/8"  # Restrict this to your IP/network
artifacts_bucket_name  = "your-artifacts-bucket-name"
capacity_type          = "ON_DEMAND"    # ON_DEMAND or SPOT
```

### Step 3: Initialize Terraform

Initialize Terraform to download providers and modules:

```bash
terraform init
```

### Step 4: Validate Configuration

Validate the configuration to catch syntax errors and other issues:

```bash
terraform validate
```

### Step 5: Review the Execution Plan

Generate and review the execution plan:

```bash
terraform plan -out=tfplan
```

Review the plan carefully to ensure:
- All required resources will be created
- No unexpected resources will be modified or destroyed
- Tags and naming conventions are applied correctly

### Step 6: Apply the Configuration

Apply the Terraform configuration to build the infrastructure:

```bash
terraform apply tfplan
```

The deployment will take approximately 15-20 minutes. The process creates:
1. VPC and networking components (5-7 minutes)
2. IAM roles and security groups (1-2 minutes)
3. CI/CD servers (5-7 minutes)
4. EKS cluster and node groups (10-15 minutes)

### Step 7: Accessing Your Infrastructure

After successful deployment, access your infrastructure components:

#### Jenkins Server Access
```bash
# Get the private IP of the Jenkins server
JENKINS_IP=$(terraform output -raw jenkins_private_ip)

# Access Jenkins at:
# http://${JENKINS_IP}:8080
```

#### SonarQube Server Access
```bash
# Get the private IP of the SonarQube server
SONARQUBE_IP=$(terraform output -raw sonarqube_private_ip)

# Access SonarQube at:
# http://${SONARQUBE_IP}:9000
```

#### Nexus Repository Manager Access
```bash
# Get the private IP of the Nexus server
NEXUS_IP=$(terraform output -raw nexus_private_ip)

# Access Nexus at:
# http://${NEXUS_IP}:8081
```

#### EKS Cluster Access
```bash
# Update your kubeconfig file
aws eks update-kubeconfig --region $(terraform output -raw region) --name $(terraform output -raw cluster_name)

# Verify cluster connectivity
kubectl get nodes
```

## Detailed Infrastructure Components

### VPC Module
- **Main VPC**: CIDR range configurable, default 10.0.0.0/16
- **Public Subnets**: For load balancers and NAT gateways
- **Private Subnets**: For application workloads and CI/CD tools
- **Internet Gateway**: Provides internet access for public subnets
- **NAT Gateway**: Enables outbound internet for resources in private subnets
- **Route Tables**: Separate tables for public and private subnets

### CI/CD Module
- **Jenkins Server**:
  - Running on EC2 in a private subnet
  - Secured with custom security groups
  - CI/CD pipeline orchestration
  - IAM role with required permissions

- **SonarQube Server**:
  - Code quality and security scanning
  - PostgreSQL database for persistent storage
  - Custom security groups limiting access
  - IAM role with minimal required permissions

- **Nexus Repository Manager**:
  - Artifact management and storage
  - Custom security groups limiting access
  - IAM role for S3 integration
  - Optimized storage configuration

- **Artifact Storage**:
  - S3 bucket with versioning enabled
  - Server-side encryption
  - Access restricted to CI/CD components
  - Lifecycle policies for cost management

### EKS Module
- **EKS Cluster**:
  - Kubernetes control plane managed by AWS
  - Private API endpoint with optional public access
  - CloudWatch logs integration for control plane logs
  - Custom security groups for cluster components

- **Node Groups**:
  - Managed node groups for worker nodes
  - Auto-scaling configuration
  - Instance type selection for cost optimization
  - Option to use Spot instances for non-critical workloads
  - IAM roles with required permissions

## Security Features

### Network Security
- **Network Segmentation**: Public and private subnets with appropriate routing
- **Security Groups**: Principle of least privilege for all components
- **Network ACLs**: Additional layer of network security
- **Private Endpoints**: For AWS services to avoid traversing the public internet

### Access Control
- **IAM Roles**: Following the principle of least privilege
- **SSH Access Control**: Restricted to specified CIDR blocks
- **Security Group Rules**: Limited to necessary ports and protocols
- **EKS RBAC**: Role-based access control for Kubernetes resources

### Data Security
- **Encryption at Rest**: S3 buckets with server-side encryption
- **Encryption in Transit**: TLS for API communications
- **State File Security**: Encrypted and versioned state in S3
- **Secret Management**: Systems for managing sensitive information

## Maintenance and Operations

### Infrastructure Updates
```bash
# Pull latest changes
git pull

# Plan changes
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan
```

### Scaling the Infrastructure
- **EKS Node Groups**: Adjust desired, min, and max capacity
- **Instance Types**: Modify for better cost or performance
- **Subnet Sizing**: Plan for growth with appropriate CIDR blocks

### Monitoring and Logging
- **CloudWatch**: For monitoring EC2 instances and EKS clusters
- **CloudTrail**: For auditing AWS API calls
- **EKS Control Plane Logs**: For Kubernetes API server diagnostics
- **VPC Flow Logs**: For network traffic analysis

### Disaster Recovery
- **Terraform State**: Versioned and backed up in S3
- **Infrastructure as Code**: Enables rapid recovery
- **Regular Backups**: Recommended for application data
- **Multi-AZ Architecture**: Provides resilience against AZ failures

## Cost Optimization

- **Right-sizing**: Choose appropriate instance types
- **Auto Scaling**: Scale resources based on demand
- **Spot Instances**: Use for non-critical workloads
- **Resource Tagging**: Implement for cost allocation
- **Reserved Instances**: Consider for stable, long-running workloads

## Troubleshooting

### Common Issues and Solutions

#### VPC/Networking Issues
- **Connectivity Problems**: Check route tables, NAT Gateway, and security groups
- **Subnet IP Exhaustion**: Verify CIDR sizing and allocation
- **Security Group Rules**: Ensure necessary ports are open

#### EKS Issues
- **Node Group Failure**: Check IAM roles and instance types
- **API Server Access**: Verify VPC endpoints and security groups
- **Authentication Problems**: Check AWS CLI configuration and kubeconfig

#### CI/CD Tools Access
- **Server Unreachable**: Check security group rules and networking
- **Service Not Starting**: Check user data scripts and instance logs
- **Permission Issues**: Verify IAM roles and policies

## Contributing

We welcome contributions to improve this infrastructure:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions and support:
- Create an issue in the project repository
- Document any bugs with detailed reproduction steps
- Provide context such as Terraform version and AWS region