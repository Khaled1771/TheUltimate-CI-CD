# Jenkins CI/CD Pipeline Configuration

This directory contains the configuration and scripts for setting up and managing Jenkins pipelines for the Ultimate CI/CD project. Jenkins is the core CI/CD tool that automates the build, test, and deployment processes.

## Overview

The Jenkins pipeline is divided into two main components:

1. **CI Pipeline**: Focuses on building, testing, and packaging the application
2. **CD Pipeline**: Handles the deployment of the application to Kubernetes

These pipelines leverage tools like Maven, Docker, and Kubernetes to ensure a robust and automated workflow.

## Prerequisites

Before setting up the Jenkins pipeline, ensure you have:

1. **Jenkins Server**:
   - A running Jenkins instance (set up via Terraform and Ansible from previous steps)
   - Initial admin password retrieved and Jenkins configured with an admin user

2. **Required Plugins**:
   - The plugins listed in `plugins.txt` should be installed
   - You can install them via the Jenkins UI or using the Jenkins CLI

3. **Credentials Configuration**:
   - Docker Hub credentials for pushing images
   - Git credentials for accessing the repository
   - Kubernetes credentials for deployment

## Jenkins Initial Setup

### Step 1: Access Jenkins

Access your Jenkins instance at `http://<JENKINS_IP>:8080`

```bash
# Get the initial admin password (from your local machine)
ssh ec2-user@<JENKINS_IP> "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
```

### Step 2: Install Required Plugins

1. Navigate to "Manage Jenkins" > "Manage Plugins" > "Available"
2. Search for and install the following plugins:
   - Pipeline
   - Git Integration
   - Docker Pipeline
   - Kubernetes CLI
   - Maven Integration
   - JUnit
   - Credentials Binding
   - Email Extension
   - Timestamper

Alternatively, you can use the script in this directory to install plugins automatically:

```bash
# Upload the plugins.txt to Jenkins server
scp plugins.txt ec2-user@<JENKINS_IP>:/tmp/

# SSH to the server and run
ssh ec2-user@<JENKINS_IP>
sudo jenkins-plugin-cli --plugin-file /tmp/plugins.txt
```

### Step 3: Configure Tools

Navigate to "Manage Jenkins" > "Global Tool Configuration" and set up:

1. **JDK**:
   - Name: `jdk17`
   - Install automatically or provide path to installation

2. **Maven**:
   - Name: `maven3`
   - Install automatically or provide path to installation

3. **Docker**:
   - Name: `docker`
   - Installation path: `/usr/bin/docker` (should be installed by Ansible)

### Step 4: Configure Credentials

Navigate to "Manage Jenkins" > "Manage Credentials" > "Global" > "Add Credentials" and add:

1. **Docker Hub**:
   - Kind: Username with password
   - ID: `docker-cred`
   - Username: Your Docker Hub username
   - Password: Your Docker Hub password

2. **Git Credentials** (if using private repository):
   - Kind: Username with password
   - ID: `git-cred`
   - Username/Password: Your git credentials

3. **Kubernetes**:
   - Kind: Secret file
   - ID: `kubeconfig`
   - File: Upload your kubeconfig file

## Pipeline Configuration

### CI Pipeline Setup

1. Create a new Pipeline job in Jenkins:
   - Click "New Item"
   - Enter a name (e.g., "BoardGame-CI")
   - Select "Pipeline" and click "OK"

2. Configure the pipeline:
   - Under "Pipeline", select "Pipeline script from SCM"
   - Select "Git" as SCM
   - Enter your repository URL
   - Specify the branch (e.g., `main`, `master`, or `dev`)
   - Script path: `Jenkins/Jenkinsfile`
   - Click "Save"

### CD Pipeline Setup (Optional)

1. Create another Pipeline job for deployment:
   - Click "New Item"
   - Enter a name (e.g., "BoardGame-CD")
   - Select "Pipeline" and click "OK"

2. Configure the CD pipeline:
   - Same as CI, but use `Jenkins/cd-pipeline/Jenkinsfile` if available

### Understanding the Jenkinsfile

The `Jenkinsfile` in this directory defines a declarative pipeline with the following stages:

1. **Git Checkout**: Retrieves source code from the repository
2. **Compile**: Compiles the application using Maven
3. **Test**: Runs unit tests to ensure code quality
4. **File System Scan**: Scans the code for security vulnerabilities
5. **Build**: Packages the application using Maven
6. **Build & Tag Docker Image**: Creates a Docker image of the application
7. **Docker Image Scan**: Scans the Docker image for vulnerabilities
8. **Push Docker Image**: Pushes the image to Docker Hub

## Running the Pipeline

1. Navigate to your CI pipeline job
2. Click "Build Now" to start the pipeline
3. Monitor the progress in the "Stage View"
4. Once complete, navigate to the CD pipeline if configured, and click "Build Now"

## Customizing the Pipeline

To customize the pipeline for your specific needs:

1. **Modify the Jenkinsfile**:
   - Add or remove stages as needed
   - Adjust the build and test commands for your project
   - Update Docker image names and tags
   
2. **Change Build Parameters**:
   - Environment variables can be modified in the Jenkinsfile
   - Add parameters in the job configuration for dynamic values

## Troubleshooting

### Common Issues

1. **Pipeline Fails at Git Checkout**:
   - Check if the Git credentials are correctly configured
   - Verify the repository URL and branch name

2. **Build or Test Failures**:
   - Examine the console output for specific error messages
   - Verify that the project structure matches what the Jenkinsfile expects

3. **Docker Issues**:
   - Ensure Docker is installed and the Jenkins user has permissions
   - Verify Docker Hub credentials are correctly configured

4. **Security Scan Failures**:
   - Review the scan reports to address identified vulnerabilities
   - Adjust scan severity thresholds if needed for initial deployment

## Next Steps

Once your Jenkins pipeline is set up and running successfully:

1. Customize the pipeline for your specific workflow needs
2. Configure webhooks for automatic pipeline triggers on code changes
3. Proceed to the [Kubernetes directory](../Kubernetes/) to set up the deployment manifests