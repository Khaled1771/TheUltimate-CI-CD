# CI/CD Pipeline with AWS EKS, Jenkins, Nexus, SonarQube, and Prometheus

Welcome to the CI/CD Pipeline project! This repository provides the infrastructure and deployment configurations to set up a robust continuous integration and continuous deployment (CI/CD) system on AWS using Amazon EKS, Jenkins, Nexus, SonarQube, and Prometheus. The setup leverages Terraform for infrastructure provisioning and Helm for deploying applications on Kubernetes.

## Project Overview

This project establishes an automated CI/CD pipeline for building, testing, and deploying applications on a Kubernetes cluster hosted on AWS EKS. Key components include:

- **AWS EKS**: A managed Kubernetes service for running containerized workloads.
- **Jenkins**: An automation server managing the CI/CD workflow.
- **Nexus**: A repository manager for storing build artifacts.
- **SonarQube**: A tool for code quality and security analysis.
- **Prometheus**: A monitoring solution for cluster and application performance.
- **Terraform**: Infrastructure as Code (IaC) for provisioning AWS resources.
- **Helm**: A Kubernetes package manager for streamlined application deployment.

The pipeline ensures automated workflows with integrated monitoring and quality checks.

---

## Prerequisites

To deploy this project, ensure you have the following in place:

- An active AWS account with permissions to create resources like VPCs, EKS clusters, and IAM roles.
- Tools installed locally: Terraform, Helm, kubectl, and Git.
- Optional: A registered domain name for configuring external access to services.

---

## Deployment Steps

Follow these steps to set up the CI/CD pipeline, with commands provided for key actions:

### 1. Clone the Repository

Download the project files from this GitHub repository to your local machine.

```bash
git clone https://github.com/Khaled1771/TheUltimate-CI-CD.git
cd TheUltimate-CI-CD/
```

### 2. Provision AWS Infrastructure

Use Terraform to create the necessary AWS infrastructure, including a VPC, subnets, an EKS cluster, and associated IAM roles.

- Navigate to the Terraform directory:
  ```bash
  cd terraform/
  ```

- Initialize Terraform:
  ```bash
  terraform init
  ```

- Apply the configuration to provision resources:
  ```bash
  terraform apply
  ```

  Review the plan and type `yes` to confirm.

### 3. Configure Kubernetes Access

Once the EKS cluster is ready, configure your local Kubernetes client (`kubectl`) to connect to the cluster.

- Update your kubeconfig:
  ```bash
  aws eks --region us-east-1 update-kubeconfig --name eks-cluster
  ```

- Verify the connection:
  ```bash
  kubectl get nodes
  ```

  You should see a list of nodes in the `Ready` state.

### 4. Deploy CI/CD Tools

Deploy Jenkins, Nexus, SonarQube, and Prometheus to the EKS cluster using Helm charts.

- Add the required Helm repositories:
  ```bash
  helm repo add jenkins https://charts.jenkins.io
  helm repo add sonatype https://sonatype.github.io/helm3-charts
  helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update
  ```

- Install each application:
  ```bash
  helm install jenkins jenkins/jenkins --set persistence.storageClass=gp2,persistence.size=10Gi
  helm install nexus sonatype/nexus-repository-manager
  helm install sonarqube sonarqube/sonarqube --set persistence.enabled=true,persistence.storageClass=gp2
  helm install prometheus prometheus-community/prometheus
  ```

- Set up the NGINX Ingress Controller:
  ```bash
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm repo update
  helm install ingress-nginx ingress-nginx/ingress-nginx
  ```

### 5. Set Up Ingress for External Access

Configure Ingress resources to enable external access to the deployed services.

- Apply Ingress configurations for each service:
  ```bash
  kubectl apply -f k8s/jenkins-ingress.yaml
  kubectl apply -f k8s/nexus-ingress.yaml
  kubectl apply -f k8s/sonarqube-ingress.yaml
  kubectl apply -f k8s/prometheus-ingress.yaml
  ```

- Retrieve the Ingress controller’s external address:
  ```bash
  kubectl get svc ingress-nginx-controller -n ingress-nginx
  ```

- If using a custom domain, update your DNS records to point to this address.

### 6. Configure Jenkins for CI/CD

Access the Jenkins instance and complete the initial setup.

- Get the Jenkins initial admin password:
  ```bash
  kubectl exec -it <jenkins-pod-name> -- cat /var/jenkins_home/secrets/initialAdminPassword
  ```

  Replace `<jenkins-pod-name>` with the actual pod name (e.g., use `kubectl get pods` to find it).

- Access Jenkins at `http://jenkins.example.com` and follow the setup wizard.
- Install necessary plugins: Git, Docker, Kubernetes, SonarQube Scanner, Nexus Artifact Uploader.
- Configure a pipeline job to automate the CI/CD workflow.

### 7. Enable Monitoring with Prometheus

Verify that Prometheus is running and monitoring the cluster.

- Check if Prometheus is accessible:
  ```bash
  kubectl port-forward svc/prometheus-server 9090:80
  ```

  Then, access `http://localhost:9090` in your browser.

- Optionally, deploy Grafana for enhanced visualization.

---

## Project Structure

The repository is organized as follows:

- **`terraform/`**: Contains Terraform configurations for AWS infrastructure.
- **`helm/`**: Holds custom Helm values files for deploying Jenkins, Nexus, SonarQube, and Prometheus.
- **`k8s/`**: Includes Ingress configuration files for external access.
- **`README.md`**: This file, providing an overview and deployment guidance.

---

## Additional Notes

- **Customization**: Modify Helm values or Terraform configurations to suit your specific needs, such as storage sizes or resource limits.
- **Security**: Implement Kubernetes RBAC and AWS IAM policies to secure the setup.
- **Scaling**: Adjust the EKS node group or enable auto-scaling for optimal performance.
- **Maintenance**: Regularly back up persistent data and cluster configurations.

For detailed settings and adjustments, explore the files within the respective directories.
