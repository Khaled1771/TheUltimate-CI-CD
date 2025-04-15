# Provider Configuration
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# Data Source for Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones  = var.availability_zones
  environment         = var.environment
  project_name        = var.project_name
  
  tags = {
    ManagedBy   = "Terraform"
    Environment = var.environment
    Project     = var.project_name
  }
}

# CI/CD Infrastructure Module
module "cicd_infrastructure" {
  source = "./modules/cicd"
  
  # Required variables
  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  public_subnet_ids    = module.vpc.public_subnet_ids
  key_name             = var.key_name
  admin_cidr           = var.admin_cidr
  artifacts_bucket_name = var.artifacts_bucket_name
  
  ami_id = var.ami_id != null ? var.ami_id : data.aws_ami.amazon_linux_2.id
  
  instance_type                = var.instance_type
  jenkins_role_arn             = aws_iam_role.jenkins.arn
  jenkins_instance_profile_name = aws_iam_instance_profile.jenkins.name
  sonarqube_role_arn           = aws_iam_role.sonarqube.arn
  sonarqube_instance_profile_name = aws_iam_instance_profile.sonarqube.name
  nexus_role_arn               = aws_iam_role.nexus.arn
  nexus_instance_profile_name  = aws_iam_instance_profile.nexus.name
  
  depends_on = [
    module.vpc,
    aws_s3_bucket.artifacts
  ]
}

# EKS Module
module "eks" {
  source = "./modules/eks"
  
  cluster_name         = var.cluster_name
  cluster_version      = var.cluster_version
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  environment          = var.environment
  project_name         = var.project_name
  key_name             = var.key_name

  # Node group configuration
  node_instance_types   = var.node_instance_types
  node_desired_capacity = var.node_desired_capacity
  node_max_capacity     = var.node_max_capacity
  node_min_capacity     = var.node_min_capacity

  # IAM and security
  eks_cluster_role_arn    = aws_iam_role.eks_cluster.arn
  eks_node_group_role_arn = aws_iam_role.eks_node_group.arn
  
  # Dependencies
  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly
  ]
}