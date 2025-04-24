# Ansible Configuration for CI/CD Pipeline

This directory contains Ansible playbooks and configuration files for setting up and managing the CI/CD tools and deployments in the Ultimate CI/CD project. Ansible is used for configuration management, application deployment, and orchestration of the CI/CD pipeline components.

## Overview

The Ansible configuration is organized into several playbooks, each serving a specific purpose in the CI/CD pipeline:

1. **Installation Playbook**: Configures and installs the necessary tools on the infrastructure (Jenkins, SonarQube, Nexus).
2. **Docker Playbook**: Manages Docker container deployments for development and testing.
3. **Deployment Playbook**: Handles application deployment to Kubernetes.
4. **Verification Playbook**: Validates successful deployments and performs health checks.

These playbooks work together to ensure consistent, repeatable configuration and deployment across environments.

## Prerequisites

Before using these playbooks, ensure the following prerequisites are met:

1. **Ansible Installation**:
   - Ansible 2.9 or later installed on the control node.
   - Python 3.x installed on both control node and managed hosts.

2. **SSH Access**:
   - SSH keys configured for passwordless authentication to target hosts.
   - Sudo privileges on target hosts.

3. **Infrastructure**:
   - The Terraform infrastructure is deployed, including EC2 instances and Kubernetes cluster.
   - DNS resolution for the target hosts is properly configured.

4. **Inventory Configuration**:
   - Inventory file updated with the correct host information.

## Playbooks

### Installation Playbook (`installation.yml`)

This playbook sets up the CI/CD tools on the provisioned instances:

- **Jenkins Configuration**:
  - Installs Java, Jenkins, Docker, and required dependencies.
  - Configures Jenkins with necessary plugins and initial settings.
  - Sets up Docker integration for containerized builds.

- **SonarQube Configuration**:
  - Installs SonarQube as a Docker container.
  - Configures database and initializes quality profiles.

- **Nexus Configuration**:
  - Deploys Nexus Repository Manager as a Docker container.
  - Configures repositories for Maven artifacts and Docker images.

### Docker Playbook (`docker.yml`)

This playbook manages Docker container deployments:

- Pulls the application Docker image from a registry.
- Stops any existing containers for the application.
- Runs the container with proper port mapping and restart policies.
- Configures networking and volume mounts as needed.

### Deployment Playbook (`deployment.yml`)

This playbook handles Kubernetes deployments:

- Applies Kubernetes manifests for the application deployment.
- Configures load balancer and ingress rules.
- Manages Kubernetes resources like ConfigMaps and Secrets.

### Verification Playbook (`verify-deployment.yml`)

This playbook validates deployments:

- Checks if pods are running correctly.
- Verifies service availability and endpoint responses.
- Reports deployment status.

## Inventory

The `inventory` file defines the hosts and groups for Ansible to manage:

```ini
[jenkins]
jenkins-server ansible_host=<jenkins-ip> ansible_user=ubuntu

[sonarqube]
sonarqube-server ansible_host=<sonarqube-ip> ansible_user=ubuntu

[nexus]
nexus-server ansible_host=<nexus-ip> ansible_user=ubuntu

[kubernetes]
k8s-master ansible_host=<kubernetes-master-ip> ansible_user=ubuntu
```

## Usage

### Running the Installation Playbook

```bash
ansible-playbook -i inventory installation.yml
```

### Deploying an Application to Docker

```bash
ansible-playbook -i inventory docker.yml --extra-vars "docker_image=myapp docker_tag=latest"
```

### Deploying an Application to Kubernetes

```bash
ansible-playbook -i inventory deployment.yml
```

### Verifying a Deployment

```bash
ansible-playbook -i inventory verify-deployment.yml
```

## Best Practices

1. **Idempotence**: All playbooks are designed to be idempotent, meaning they can be run multiple times without causing problems.

2. **Variable Usage**: Sensitive information and environment-specific configurations are stored as variables.

3. **Role-Based Organization**: Complex configurations are organized into roles for better reusability.

4. **Error Handling**: Playbooks include proper error handling and reporting.

5. **Security**: Sensitive data is encrypted using Ansible Vault.

## Troubleshooting

### Common Issues

1. **Connection Failures**:
   - Ensure SSH keys are properly configured.
   - Verify that the target hosts are reachable.
   - Check firewall rules and security groups.

2. **Permission Issues**:
   - Ensure the Ansible user has sudo privileges.
   - Verify file permissions on the target hosts.

3. **Docker Issues**:
   - Check Docker service status on the target hosts.
   - Verify Docker registry credentials if pulling private images.

4. **Kubernetes Deployment Failures**:
   - Ensure `kubectl` is properly configured on the target host.
   - Verify Kubernetes resource limits and quotas.
   - Check for syntax errors in the Kubernetes manifests.

## Support

For questions or support, please contact the project maintainers or refer to the Ansible documentation.