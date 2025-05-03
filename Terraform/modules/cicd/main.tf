# Jenkins Instance
resource "aws_instance" "jenkins" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_ids[0]  # Changed from private to public subnet
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  iam_instance_profile   = var.jenkins_instance_profile_name
  associate_public_ip_address = true  # Ensure public IP address is assigned
  tags = {
    Name        = "${var.project_name}-jenkins"
    Environment = var.environment
  }
}

# Nexus Instance
resource "aws_instance" "nexus" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_ids[0]  # Changed from private to public subnet
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.nexus.id]
  iam_instance_profile   = var.nexus_instance_profile_name
  associate_public_ip_address = true  # Ensure public IP address is assigned
  
  
  tags = {
    Name        = "${var.project_name}-nexus"
    Environment = var.environment
  }
}

# Jenkins Security Group
resource "aws_security_group" "jenkins" {
  name        = "${var.project_name}-jenkins-sg"
  description = "Security group for Jenkins server"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
    description = "SSH access from admin CIDR"
  }
  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
    description = "Jenkins web interface from admin CIDR"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = {
    Name        = "${var.project_name}-jenkins-sg"
    Environment = var.environment
  }
}

# Nexus Security Group
resource "aws_security_group" "nexus" {
  name        = "${var.project_name}-nexus-sg"
  description = "Security group for Nexus server"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
    description = "SSH access from admin CIDR"
  }
  
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
    description = "Nexus web interface from admin CIDR"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = {
    Name        = "${var.project_name}-nexus-sg"
    Environment = var.environment
  }
}
