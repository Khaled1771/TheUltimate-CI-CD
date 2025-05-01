# Jenkins CI/CD Pipeline

This directory contains the configuration and scripts for setting up and managing Jenkins pipelines for the Ultimate CI/CD project. Jenkins is used as the core CI/CD tool to automate the build, test, and deployment processes.

## Overview

The Jenkins pipelines are divided into two main categories:

1. **CI Pipeline**: Focuses on building, testing, and packaging the application.
2. **CD Pipeline**: Handles the deployment of the application to Kubernetes.

These pipelines are defined using Jenkinsfiles and leverage tools like Maven, Docker, SonarQube, and Ansible to ensure a robust and automated workflow.

## Prerequisites

Before setting up Jenkins, ensure the following prerequisites are met:

1. **Jenkins Server**:
   - A Jenkins server is installed and running.
   - Required plugins are installed (see `plugins.txt`).

2. **Credentials**:
   - Git credentials for accessing the repository.
   - Docker Hub credentials for pushing images.
   - SonarQube credentials for quality analysis.

3. **Tools**:
   - Docker installed on the Jenkins server.
   - Maven installed and configured.
   - SonarQube server accessible.

4. **Infrastructure**:
   - The Terraform infrastructure is deployed, including the Kubernetes cluster and S3 buckets.

## Pipeline Structure

### CI Pipeline

The CI pipeline is defined in `ci pipeline/Jenkinsfile` and includes the following stages:

1. **Git Checkout**: Clones the repository from the specified branch.
2. **Compile**: Compiles the application using Maven.
3. **Test**: Runs unit tests to ensure code quality.
4. **SonarQube Analysis**: Performs static code analysis using SonarQube.
5. **Build**: Packages the application into a deployable artifact.
6. **Publish to Nexus**: Uploads the artifact to Nexus Repository Manager.
7. **Build & Tag Docker Image**: Builds a Docker image and tags it.
8. **Push Docker Image**: Pushes the Docker image to Docker Hub.

### CD Pipeline

The CD pipeline is defined in `cd pipeline/jenkinsfile` and includes the following stages:

1. **Git Checkout**: Clones the repository from the specified branch.
2. **Deploy to Kubernetes**: Deploys the application to the Kubernetes cluster using Ansible.
3. **Verify Deployment**: Verifies that the application is running as expected.

## Setting Up Jenkins

### Step 1: Install Required Plugins

Install the following plugins on your Jenkins server:

- Pipeline
- Git
- Docker Pipeline
- SonarQube Scanner
- Email Extension
- Ansible

### Step 2: Configure Credentials

Add the following credentials in Jenkins:

1. **Git Credentials**: For accessing the Git repository.
2. **Docker Hub Credentials**: For pushing Docker images.
3. **SonarQube Credentials**: For performing code analysis.

### Step 3: Configure Tools

1. **JDK**: Add JDK 17 in Jenkins global tool configuration.
2. **Maven**: Add Maven 3 in Jenkins global tool configuration.
3. **SonarQube Scanner**: Add SonarQube Scanner in Jenkins global tool configuration.

### Step 4: Create Pipelines

1. Create a new pipeline job for the CI pipeline and point it to `ci pipeline/Jenkinsfile`.
2. Create a new pipeline job for the CD pipeline and point it to `cd pipeline/jenkinsfile`.

## Running the Pipelines

1. Trigger the CI pipeline to build, test, and package the application.
2. Once the CI pipeline completes successfully, trigger the CD pipeline to deploy the application.

## Troubleshooting

### Common Issues

1. **Pipeline Fails at Git Checkout**:
   - Ensure the Git credentials are correctly configured.
   - Verify the repository URL and branch name.

2. **SonarQube Analysis Fails**:
   - Ensure the SonarQube server is accessible.
   - Verify the SonarQube credentials and project key.

3. **Docker Image Push Fails**:
   - Ensure Docker Hub credentials are correctly configured.
   - Verify the Docker Hub repository name and permissions.

4. **Deployment Fails**:
   - Ensure the Kubernetes cluster is running and accessible.
   - Verify the Ansible inventory and playbooks.

## Support

For questions or support, please contact the project maintainers or refer to the Jenkins documentation.