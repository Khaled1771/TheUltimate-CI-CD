# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

# EKS Outputs
output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

# CI/CD Infrastructure Outputs
output "jenkins_public_ip" {
  description = "Public IP address of the Jenkins server"
  value       = module.cicd_infrastructure.jenkins_public_ip
}

output "jenkins_private_ip" {
  description = "Private IP address of the Jenkins server"
  value       = module.cicd_infrastructure.jenkins_private_ip
}

output "sonarqube_public_ip" {
  description = "Public IP address of the SonarQube server"
  value       = module.cicd_infrastructure.sonarqube_public_ip
}

output "sonarqube_private_ip" {
  description = "Private IP address of the SonarQube server"
  value       = module.cicd_infrastructure.sonarqube_private_ip
}

output "nexus_public_ip" {
  description = "Public IP address of the Nexus server"
  value       = module.cicd_infrastructure.nexus_public_ip
}

output "nexus_private_ip" {
  description = "Private IP address of the Nexus server"
  value       = module.cicd_infrastructure.nexus_private_ip
}

# Storage Outputs
output "artifacts_bucket_name" {
  description = "Name of the S3 bucket for artifacts"
  value       = aws_s3_bucket.artifacts.id
}

output "cache_bucket_name" {
  description = "Name of the S3 bucket for cache"
  value       = aws_s3_bucket.cache.id
}

# Region for reference in scripts
output "region" {
  description = "AWS region used"
  value       = var.aws_region
}