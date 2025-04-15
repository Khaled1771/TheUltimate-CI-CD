variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of private subnets"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "IDs of public subnets"
  type        = list(string)
}

variable "instance_type" {
  description = "Instance type for the CI/CD servers"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "AMI ID for CI/CD servers"
  type        = string
  default     = null
}

variable "key_name" {
  description = "SSH key name for the instances"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "Name of the S3 bucket to store artifacts"
  type        = string
}

variable "jenkins_version" {
  description = "Version of Jenkins to install"
  type        = string
  default     = "latest"
}

variable "jenkins_role_arn" {
  description = "ARN of the IAM role for Jenkins"
  type        = string
  default     = null
}

variable "jenkins_instance_profile_name" {
  description = "Name of the instance profile for Jenkins"
  type        = string
  default     = null
}

variable "nexus_version" {
  description = "Version of Nexus Repository to install"
  type        = string
  default     = "latest"
}

variable "nexus_role_arn" {
  description = "ARN of the IAM role for Nexus"
  type        = string
  default     = null
}

variable "nexus_instance_profile_name" {
  description = "Name of the instance profile for Nexus"
  type        = string
  default     = null
}

variable "sonarqube_version" {
  description = "Version of SonarQube to install"
  type        = string
  default     = "latest"
}

variable "sonarqube_role_arn" {
  description = "ARN of the IAM role for SonarQube"
  type        = string
  default     = null
}

variable "sonarqube_instance_profile_name" {
  description = "Name of the instance profile for SonarQube"
  type        = string
  default     = null
}

variable "admin_cidr" {
  description = "CIDR block for admin access to CI/CD tools"
  type        = string
}