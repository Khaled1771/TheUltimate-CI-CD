# Enterprise Kubernetes Deployment

This repository contains the Kubernetes manifests and Helm charts for deploying a complete enterprise-grade application on a Kubernetes cluster. The deployment is designed to be scalable, secure, and follows Kubernetes best practices.

## Architecture Overview

The Kubernetes deployment consists of three main components:

### 1. Application Deployment
- Board game application deployed using Deployments for reliable pod management
- Resource limits and requests for optimal resource utilization
- Pod disruption budgets for high availability
- Readiness and liveness probes for self-healing capabilities
- Horizontal Pod Autoscaler for dynamic scaling

### 2. Services and Networking
- ClusterIP Services for internal communication
- LoadBalancer/NodePort Services for external access
- Ingress controller for HTTP/HTTPS routing
- Network policies for secure pod-to-pod communication
- Service mesh options for advanced traffic management

### 3. Configuration and Storage
- ConfigMaps for non-sensitive configuration data
- Secrets for sensitive configuration information
- Persistent Volumes for stateful workloads
- StorageClasses for dynamic volume provisioning
- Init Containers for complex application initialization

## Installing Prerequisites

Before proceeding, ensure you have the following tools installed:

### kubectl
```bash
# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

# macOS
brew install kubectl
kubectl version --client

# Windows
choco install kubernetes-cli
kubectl version --client
```

### Helm
```bash
# Linux
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version

# macOS
brew install helm
helm version

# Windows
choco install kubernetes-helm
helm version
```

## Prerequisites

Before deploying the application, you need:

1. A running Kubernetes cluster (EKS, GKE, AKS, or self-managed)
2. `kubectl` configured to communicate with your cluster
3. Helm 3 installed
4. Access permissions to create resources in your namespace
5. Container registry access for pulling application images

## Deployment Instructions

### Step 1: Configure Kubernetes Context

Ensure you're connected to the right cluster and namespace:

```bash
# Check current context
kubectl config current-context

# Create and switch to a dedicated namespace (optional but recommended)
kubectl create namespace board-game-app
kubectl config set-context --current --namespace=board-game-app
```

### Step 2: Configure Values

1. Create a custom values file based on the example:

```bash
# Create your values file
cp values.yaml.example my-values.yaml

# Edit the file with your settings
nano my-values.yaml
```

2. Configure the required and optional values:

```yaml
# Required Values
image:
  repository: your-registry/board-game
  tag: latest
  pullPolicy: Always

service:
  type: ClusterIP
  port: 8080

# Optional - Set to override defaults
replicas: 2
resources:
  limits:
    cpu: "500m"
    memory: "512Mi"
  requests:
    cpu: "200m"
    memory: "256Mi"
ingress:
  enabled: true
  className: "nginx"
  host: "boardgame.example.com"
  tls:
    enabled: true
```

### Step 3: Install TLS Certificate (if needed)

If using TLS with your ingress, create the required secret:

```bash
# Create TLS secret from existing certificates
kubectl create secret tls boardgame-tls --key=/path/to/tls.key --cert=/path/to/tls.crt

# Or use cert-manager to automate certificate management (recommended)
# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.0/cert-manager.yaml

# Create an issuer
kubectl apply -f issuer.yaml
```

### Step 4: Deploy Using Helm

Deploy the application using Helm:

```bash
# Add the helm repository (if using a shared repository)
helm repo add myrepo https://charts.example.com
helm repo update

# Install directly from your chart directory
helm install boardgame ./board-game-chart -f my-values.yaml

# Or install from a repository
helm install boardgame myrepo/board-game -f my-values.yaml
```

The deployment will create:
1. Kubernetes Deployment with configured replicas
2. Service for internal and/or external access
3. Ingress resource (if enabled)
4. ConfigMaps and Secrets for application configuration
5. ServiceAccount with appropriate RBAC settings

### Step 5: Verify the Deployment

Verify that all components are running correctly:

```bash
# Check deployment status
kubectl get deployments

# Check pods status
kubectl get pods

# Check services
kubectl get svc

# Check ingress
kubectl get ingress

# View detailed information about the deployment
kubectl describe deployment boardgame
```

### Step 6: Accessing Your Application

After successful deployment, access your application:

```bash
# For ClusterIP services with port forwarding
kubectl port-forward svc/boardgame 8080:8080

# For LoadBalancer services
EXTERNAL_IP=$(kubectl get svc boardgame -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Access your application at: http://${EXTERNAL_IP}:8080"

# For Ingress
HOSTNAME=$(kubectl get ingress boardgame-ingress -o jsonpath='{.spec.rules[0].host}')
echo "Access your application at: https://${HOSTNAME}"
```

## Detailed Deployment Components

### Application Deployment
- **Deployment**: Manages pod lifecycle and ensures the desired number of replicas
- **ReplicaSets**: Created automatically by Deployments for pod management
- **Pods**: Contain your application containers with appropriate resource settings
- **Autoscaling**: HorizontalPodAutoscaler for automatic scaling based on CPU/Memory

### Services and Networking
- **ClusterIP Service**: Internal-only service for pod-to-pod communication
- **LoadBalancer/NodePort**: External-facing services for end-user access
- **Ingress**: HTTP/HTTPS routing with hostname-based virtual hosting
- **NetworkPolicies**: Firewall rules for pod traffic control

### Configuration and Storage
- **ConfigMaps**: For environment variables, config files, and command-line arguments
- **Secrets**: For sensitive information like passwords and tokens
- **PersistentVolumes**: For durable storage across pod restarts
- **PersistentVolumeClaims**: Request storage resources for pods

## Security Features

### Pod Security
- **Security Context**: Run containers with non-root users
- **PodSecurityPolicies**: Enforce security best practices
- **Container Image Security**: Use trusted images and scan for vulnerabilities
- **Resource Limits**: Prevent resource exhaustion attacks

### Authentication and Authorization
- **ServiceAccounts**: Identity for pods to interact with the API server
- **RBAC**: Role-based access control for resources
- **Network Policies**: Control traffic between pods
- **Secret Management**: Properly handle sensitive information

### TLS and Network Security
- **Ingress TLS**: HTTPS encryption for external traffic
- **mTLS**: Mutual TLS for service-to-service communication
- **Network Policies**: Control ingress and egress traffic
- **API Server Authentication**: Secure access to the Kubernetes API

## Maintenance and Operations

### Deployment Updates
```bash
# Update values file with new settings
nano my-values.yaml

# Apply the update
helm upgrade boardgame ./board-game-chart -f my-values.yaml
```

### Scaling the Application
```bash
# Manually scale deployments
kubectl scale deployment boardgame --replicas=5

# Update autoscaling configuration
kubectl edit hpa boardgame
```

### Monitoring and Logging
- **Prometheus**: For application and cluster metrics collection
- **Grafana**: For metrics visualization and dashboards
- **Loki**: For log aggregation and search
- **Jaeger/Zipkin**: For distributed tracing

### Backup and Restore
- **Velero**: For cluster-level backup and restore
- **Database Backups**: Regular backups for application data
- **Helm Revision History**: Track and rollback releases
- **GitOps**: Infrastructure as Code for disaster recovery

## Cost Optimization

- **Right-sizing**: Adjust resource requests and limits
- **Autoscaling**: Scale based on actual usage patterns
- **Node Affinity**: Optimize pod placement for cost efficiency
- **Resource Quotas**: Set limits on namespace resource consumption
- **Pod Disruption Budgets**: Balance availability and cost

## Troubleshooting

### Common Issues and Solutions

#### Deployment Issues
- **Pods Not Starting**: Check container image, resource limits, and node capacity
- **CrashLoopBackOff**: Check logs for application errors
- **ImagePullBackOff**: Verify image name and registry access
- **PodUnschedulable**: Check node resources and taints/tolerations

#### Networking Issues
- **Service Unreachable**: Check selectors, endpoints, and network policies
- **Ingress Not Working**: Verify ingress controller, annotations, and TLS config
- **DNS Resolution Problems**: Check CoreDNS and service/pod naming

#### Storage Issues
- **PVC Pending**: Check StorageClass availability and capacity
- **Volume Mount Failures**: Verify paths and permissions
- **Data Loss**: Check persistent volume reclaim policies

## Contributing

We welcome contributions to improve this Kubernetes deployment:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions and support:
- Create an issue in the project repository
- Document any bugs with detailed reproduction steps
- Provide context such as Kubernetes and Helm versions