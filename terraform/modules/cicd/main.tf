# Jenkins Instance
resource "aws_instance" "jenkins" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids[0]
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  iam_instance_profile   = var.jenkins_instance_profile_name
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y openjdk-11-jdk
    wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | apt-key add -
    sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    apt-get update
    apt-get install -y jenkins
    systemctl enable jenkins
    systemctl start jenkins
  EOF
  )
  
  tags = {
    Name        = "${var.project_name}-jenkins"
    Environment = var.environment
  }
}

# Nexus Instance
resource "aws_instance" "nexus" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids[0]
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.nexus.id]
  iam_instance_profile   = var.nexus_instance_profile_name
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y openjdk-8-jdk
    mkdir -p /opt/nexus
    cd /opt/nexus
    wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz
    tar -xvf latest-unix.tar.gz
    mv nexus-* nexus
    adduser --disabled-password --gecos "" nexus
    chown -R nexus:nexus /opt/nexus
    cat > /etc/systemd/system/nexus.service << 'END'
    [Unit]
    Description=Nexus Repository Manager
    After=network.target
    
    [Service]
    Type=forking
    ExecStart=/opt/nexus/nexus/bin/nexus start
    ExecStop=/opt/nexus/nexus/bin/nexus stop
    User=nexus
    Restart=on-abort
    
    [Install]
    WantedBy=multi-user.target
    END
    
    systemctl enable nexus
    systemctl start nexus
  EOF
  )
  
  tags = {
    Name        = "${var.project_name}-nexus"
    Environment = var.environment
  }
}

# SonarQube Instance
resource "aws_instance" "sonarqube" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids[0]
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.sonarqube.id]
  iam_instance_profile   = var.sonarqube_instance_profile_name
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y openjdk-11-jdk postgresql postgresql-contrib
    systemctl start postgresql
    systemctl enable postgresql
    
    sudo -u postgres psql -c "CREATE USER sonarqube WITH ENCRYPTED PASSWORD 'sonarqube';"
    sudo -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonarqube;"
    
    apt-get install -y unzip
    mkdir -p /opt/sonarqube
    cd /opt/sonarqube
    wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${var.sonarqube_version}.zip
    unzip sonarqube-${var.sonarqube_version}.zip
    mv sonarqube-${var.sonarqube_version} sonarqube
    
    # Configure SonarQube
    cat > /opt/sonarqube/sonarqube/conf/sonar.properties << 'END'
    sonar.jdbc.username=sonarqube
    sonar.jdbc.password=sonarqube
    sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
    END
    
    adduser --disabled-password --gecos "" sonarqube
    chown -R sonarqube:sonarqube /opt/sonarqube
    
    cat > /etc/systemd/system/sonarqube.service << 'END'
    [Unit]
    Description=SonarQube service
    After=network.target postgresql.service
    
    [Service]
    Type=forking
    ExecStart=/opt/sonarqube/sonarqube/bin/linux-x86-64/sonar.sh start
    ExecStop=/opt/sonarqube/sonarqube/bin/linux-x86-64/sonar.sh stop
    User=sonarqube
    Group=sonarqube
    Restart=on-failure
    
    [Install]
    WantedBy=multi-user.target
    END
    
    systemctl daemon-reload
    systemctl enable sonarqube
    systemctl start sonarqube
  EOF
  )
  
  tags = {
    Name        = "${var.project_name}-sonarqube"
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

# SonarQube Security Group
resource "aws_security_group" "sonarqube" {
  name        = "${var.project_name}-sonarqube-sg"
  description = "Security group for SonarQube server"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
    description = "SSH access from admin CIDR"
  }
  
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
    description = "SonarQube web interface from admin CIDR"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = {
    Name        = "${var.project_name}-sonarqube-sg"
    Environment = var.environment
  }
}
