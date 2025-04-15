output "jenkins_public_ip" {
  description = "Public IP address of the Jenkins server"
  value       = aws_instance.jenkins.public_ip
}

output "nexus_public_ip" {
  description = "Public IP address of the Nexus server"
  value       = aws_instance.nexus.public_ip
}

output "sonarqube_public_ip" {
  description = "Public IP address of the SonarQube server"
  value       = aws_instance.sonarqube.public_ip
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

output "sonarqube_security_group_id" {
  description = "ID of the SonarQube security group"
  value       = aws_security_group.sonarqube.id
}

output "jenkins_iam_role_arn" {
  description = "ARN of the Jenkins IAM role"
  value       = var.jenkins_role_arn
}