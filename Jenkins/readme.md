# Jenkins CI Pipeline Configuration

This directory contains the configuration and scripts for setting up and managing Jenkins pipelines for the Ultimate CI/CD project. Jenkins is the core Continuous Integration (CI) tool that automates the build, test, and containerization processes, while ArgoCD handles the Continuous Delivery (CD) aspect.

## Overview

In this project's workflow:

1. **CI Pipeline (Jenkins)**: Focuses on building, testing, and packaging the application as a Docker image
2. **CD Pipeline (ArgoCD)**: Handles the deployment of the application to Kubernetes using GitOps principles

The Jenkins pipeline leverages tools like Maven, Docker, and security scanners to ensure a robust and automated workflow before handing off to ArgoCD for deployment.

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
   - Timestamper
   - Prometheus metrics (for monitoring)

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

### Understanding the Jenkinsfile

The `Jenkinsfile` in this directory defines a declarative pipeline with the following stages:

1. **Git Checkout**: Retrieves source code from the repository
2. **Compile**: Compiles the application using Maven
3. **Test**: Runs unit tests to ensure code quality
4. **File System Scan**: Scans the code for security vulnerabilities
5. **Build**: Packages the application using Maven
6. **Build & Tag Docker Image**: Creates a Docker image of the application
7. **Docker Image Scan**: Scans the Docker image for vulnerabilities
8. **Push Docker Image**: Pushes the image to Docker Hub (trigger for ArgoCD)

## CI/CD Workflow Integration

### How Jenkins (CI) and ArgoCD (CD) Work Together

1. **Jenkins Responsibility (CI)**: 
   - Build and test the application code
   - Create and scan Docker images
   - Push images to Docker Hub with appropriate tags
   - Optional: Update image tag in Git repository for ArgoCD to detect

2. **ArgoCD Responsibility (CD)**:
   - Monitor Git repository for changes in Kubernetes manifests
   - Automatically deploy new versions when detected
   - Ensure deployed state matches desired state in Git
   - Provide visualization and management of deployments

For ArgoCD setup and configuration, please refer to the [Kubernetes directory](../Kubernetes/) documentation.

## Running the Pipeline

1. Navigate to your CI pipeline job
2. Click "Build Now" to start the pipeline
3. Monitor the progress in the "Stage View"
4. Once complete, ensure Docker images are pushed to Docker Hub for ArgoCD to detect

## Pushing Docker Images to Docker Hub

Ensure your Docker images are being correctly pushed to Docker Hub with appropriate tags. This is critical for ArgoCD to detect and deploy updates.

## Customizing the Pipeline

To customize the pipeline for your specific needs:

1. **Modify the Jenkinsfile**:
   - Add or remove stages as needed
   - Adjust the build and test commands for your project
   - Update Docker image names and tags
   
2. **Change Build Parameters**:
   - Environment variables can be modified in the Jenkinsfile
   - Add parameters in the job configuration for dynamic values

## Monitoring Jenkins

To monitor Jenkins performance and health:

1. **Install the Prometheus Plugin** (if not already installed)
   - Navigate to "Manage Jenkins" > "Manage Plugins" > "Available"
   - Search for and install "Prometheus metrics"
   
2. **Configure Prometheus Metrics**
   - The plugin exposes metrics at `/prometheus` endpoint
   - Verify metrics are available by visiting `http://<JENKINS_IP>:8080/prometheus/`
   
3. **Configure Prometheus to Scrape Jenkins**
   - Use the configuration in the [Monitoring directory](../Monitoring/)
   - Apply the `jenkins-scrapeConfig.yaml` to your Prometheus instance

4. **Visualize Metrics in Grafana**
   - Import the Jenkins dashboard (ID: 9964) into your Grafana instance
   - Configure alerts for key metrics like job failure rate and queue size

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

Once your Jenkins CI pipeline is set up and running successfully:

1. Ensure your Docker images are being correctly pushed to Docker Hub
2. Proceed to the [Kubernetes directory](../Kubernetes/) to set up ArgoCD for continuous delivery
3. Configure the ArgoCD application to watch your Docker image for updates
4. Set up monitoring by following the instructions in the [Monitoring directory](../Monitoring/)