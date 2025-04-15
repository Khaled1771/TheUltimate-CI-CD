# General Variables
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project for resource naming and tagging"
  type        = string
  default     = "enterprise-cicd"
}

variable "key_name" {
  description = "Name of the SSH key pair for EC2 instances"
  type        = string
  default     = "enterprise-cicd-key"  
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"  
}

# Option 1: Explicitly define subnet CIDRs (recommended for production)
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = [
    "10.0.0.0/24",   # 256 IPs in us-east-1a
    "10.0.1.0/24",   # 256 IPs in us-east-1b
    "10.0.2.0/24"    # 256 IPs in us-east-1c
  ]
  
  validation {
    condition     = length([for cidr in var.public_subnet_cidrs : cidr if split("/", cidr)[1] <= "24"]) == length(var.public_subnet_cidrs)
    error_message = "All public subnet CIDR blocks must have a prefix of /24 or larger (e.g., /23, /22)."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = [
    "10.0.10.0/24",  # 256 IPs in us-east-1a
    "10.0.11.0/24",  # 256 IPs in us-east-1b
    "10.0.12.0/24"   # 256 IPs in us-east-1c
  ]
  
  validation {
    condition     = length([for cidr in var.private_subnet_cidrs : cidr if split("/", cidr)[1] <= "24"]) == length(var.private_subnet_cidrs)
    error_message = "All private subnet CIDR blocks must have a prefix of /24 or larger (e.g., /23, /22)."
  }
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# EKS Variables
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "enterprise-cicd-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"  
}

variable "node_instance_types" {
  description = "EC2 instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.small"] 
}

variable "node_desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_max_capacity" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

variable "node_min_capacity" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

# CI/CD Infrastructure Variables
variable "artifacts_bucket_name" {
  description = "Name of the S3 bucket for storing artifacts"
  type        = string
  default     = null  
}

variable "admin_cidr" {
  description = "CIDR block for admin access to CI/CD tools"
  type        = string
  default     = "0.0.0.0/0"  
}

variable "ami_id" {
  description = "AMI ID for CI/CD servers"
  type        = string
  default     = null  
}

variable "instance_type" {
  description = "Instance type for CI/CD servers"
  type        = string
  default     = "t3.medium"
}