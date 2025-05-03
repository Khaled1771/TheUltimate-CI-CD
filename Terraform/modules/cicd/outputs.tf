output "jenkins_public_ip" {
  description = "Public IP of Jenkins server"
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_private_ip" {
  description = "Private IP of Jenkins server"
  value       = aws_instance.jenkins.private_ip
}

output "jenkins_instance_id" {
  description = "Instance ID of the Jenkins server"
  value       = aws_instance.jenkins.id
}

output "nexus_public_ip" {
  description = "Public IP of Nexus server"
  value       = aws_instance.nexus.public_ip
}

output "nexus_private_ip" {
  description = "Private IP of Nexus server"
  value       = aws_instance.nexus.private_ip
}

output "nexus_instance_id" {
  description = "Instance ID of the Nexus server"
  value       = aws_instance.nexus.id
}

output "artifacts_bucket_name" {
  description = "Name of the artifacts S3 bucket"
  value       = var.artifacts_bucket_name
}

output "jenkins_security_group_id" {
  description = "ID of the Jenkins security group"
  value       = aws_security_group.jenkins.id
}

output "nexus_security_group_id" {
  description = "ID of the Nexus security group"
  value       = aws_security_group.nexus.id
}

output "jenkins_iam_role_arn" {
  description = "ARN of the Jenkins IAM role"
  value       = var.jenkins_role_arn
}