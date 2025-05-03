# Board Game Kubernetes Deployment with ArgoCD

This directory contains the Kubernetes manifests and Helm charts for deploying the Board Game application on a Kubernetes cluster using GitOps practices with ArgoCD.

## Architecture Overview

The Kubernetes deployment consists of these main components:

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

### 4. Continuous Delivery with ArgoCD
- GitOps-based deployment automation
- Configuration-as-code for Kubernetes resources
- Automated synchronization between Git repositories and cluster state
- Deployment visualization and management through ArgoCD UI
- Support for canary deployments and progressive delivery

## Prerequisites

Before deploying the application, ensure you have:

1. A running Kubernetes cluster (EKS, GKE, AKS, or self-managed)
2. `kubectl` installed and configured to communicate with your cluster
3. Helm 3 installed
4. Access permissions to create resources in your namespace
5. Docker registry access with the application image
6. Git repository for storing Kubernetes manifests

### Installing kubectl

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

### Installing Helm

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

## ArgoCD Setup with Helm

### Step 1: Install ArgoCD using Helm

Install ArgoCD in your Kubernetes cluster using Helm:

```bash
# Add the ArgoCD Helm repository
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Create a namespace for ArgoCD
kubectl create namespace argocd

# Install ArgoCD using Helm
helm install argocd argo/argo-cd \
  --namespace argocd \
  --set server.service.type=LoadBalancer
```

For production environments, you might want to customize the installation with additional values:

```bash
# Create a values file for customization
cat > argocd-values.yaml <<EOF
server:
  service:
    type: LoadBalancer
  ingress:
    enabled: false
  extraArgs:
    - --insecure  # Only for demonstration; use proper TLS in production
controller:
  metrics:
    enabled: true
repoServer:
  metrics:
    enabled: true
dex:
  enabled: true
EOF

# Install ArgoCD with custom values
helm install argocd argo/argo-cd \
  --namespace argocd \
  -f argocd-values.yaml
```

### Step 2: Access the ArgoCD UI

After installation, get the ArgoCD server URL:

```bash
# If using LoadBalancer service type
kubectl get svc argocd-server -n argocd

# The output will include an EXTERNAL-IP. Access ArgoCD at:
# https://<EXTERNAL-IP>
```

If you don't have a LoadBalancer available (like in Minikube), use port forwarding:

```bash
# Port forward the ArgoCD server
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Then navigate to https://localhost:8080 in your browser.

### Step 3: Get the Initial Admin Password

Retrieve the initial admin password:

```bash
# Get the initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Login with username `admin` and the password retrieved above.

### Step 4: Configure ArgoCD Through the GUI

Once logged in to the ArgoCD UI, follow these steps to set up your application:

1. **Create a New Application**:
   - Click the **"+ NEW APP"** button in the top left
   - Use either the **"EDIT AS YAML"** option or fill in the form

2. **Enter Application Details**:
   - **Application Name**: `boardgame`
   - **Project**: `default`
   - **SYNC POLICY**: Select `Automatic` (for automatic deployments)
   
3. **Configure Source**:
   - **Repository URL**: Enter your Git repository URL (e.g., `https://github.com/yourusername/TheUltimate-CI-CD.git`)
   - **Revision**: `main` (or your preferred branch)
   - **Path**: `Kubernetes/board-game-chart`
   
4. **Configure Destination**:
   - **Cluster URL**: `https://kubernetes.default.svc` (uses the local cluster)
   - **Namespace**: `default` (or your preferred namespace)
   
5. **Review Helm Values (Optional)**:
   - Click on **"PARAMETERS"** tab
   - Override any Helm values as needed
   
6. **Click "CREATE"** to finalize your application

Your application will appear in the ArgoCD dashboard and begin syncing immediately if you selected automatic sync.

### Step 5: Setting Up Automatic Image Updates (Optional)

ArgoCD doesn't automatically update when new container images are available. To enable this feature:

1. **Install Argo CD Image Updater** through the UI:
   - In the ArgoCD UI, go to **"Settings"** → **"Plugins"**
   - Click on **"Install Plugin"**
   - Enter the details for the image updater plugin
   
   Or install it via Helm:
   
   ```bash
   helm repo add argo https://argoproj.github.io/argo-helm
   helm install argocd-image-updater argo/argocd-image-updater \
     --namespace argocd
   ```

2. **Configure Application for Image Updates** through the UI:
   - Go to your application in the ArgoCD UI
   - Click on **"App Details"**
   - Go to **"Parameters"** tab
   - Add the following annotations:
     - Key: `argocd-image-updater.argoproj.io/image-list`
     - Value: `boardgame=yourusername/board-game`
     - Key: `argocd-image-updater.argoproj.io/boardgame.update-strategy`
     - Value: `semver`

### Step 6: Managing Your Application in the ArgoCD UI

ArgoCD provides a rich UI for managing your applications:

1. **View Application Status**: 
   - The main dashboard shows all applications with their sync status and health
   - Click on an application to see detailed resource information
   
2. **Manual Sync**: 
   - Click the **"SYNC"** button to manually trigger a synchronization
   - You can select specific resources to sync
   
3. **View Application History**:
   - Click on **"HISTORY"** to see previous deployment states
   - Each entry shows when changes occurred and what was changed
   
4. **Rollback**:
   - In the history view, click on a previous version
   - Click **"ROLLBACK"** to revert to that version
   
5. **View Diff**:
   - Click on **"APP DIFF"** to see what will change during a sync
   - You can review changes before applying them

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
  tag: latest  # Consider using a specific version in production
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

### Step 4: Deploy Using ArgoCD

Once ArgoCD is set up and your application is configured, ArgoCD will automatically deploy your application whenever changes are pushed to your Git repository.

To manually trigger a deployment:

```bash
# Sync the application
argocd app sync boardgame
```

Monitor the sync process in the ArgoCD UI or using the CLI:

```bash
# Check the application status
argocd app get boardgame
```

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

## ArgoCD Workflow

### Continuous Delivery Process

The ArgoCD-based continuous delivery workflow works as follows:

1. **Code Changes**: Developers make changes to code and push to Git
2. **CI Pipeline**: Jenkins builds and tests the application
3. **Image Publishing**: Docker image is built and pushed to Docker Hub with a new tag
4. **Manifest Updates**: Update the Helm chart's `values.yaml` or create a pull request to update the image tag
5. **Automated Sync**: ArgoCD detects changes in Git and updates the deployment
6. **Verification**: ArgoCD reports sync status and health of the application

### Rollbacks

To rollback to a previous version:

1. In the ArgoCD UI, navigate to your application
2. Click on "History" to see previous states
3. Select the desired version and click "Rollback"

Or using the CLI:

```bash
# List application history
argocd app history boardgame

# Rollback to a specific ID
argocd app rollback boardgame <HISTORY_ID>
```

### Advanced ArgoCD Configuration

For advanced configurations:

1. **Sync Waves**: Control the order of resource creation
2. **Health Checks**: Customize health assessment
3. **Sync Windows**: Restrict when syncs can occur
4. **Notifications**: Configure alerts for sync events

## Deployment Updates

To update your application deployment:

```bash
# Update values file with new settings
git clone https://github.com/yourusername/TheUltimate-CI-CD.git
cd TheUltimate-CI-CD
nano Kubernetes/board-game-chart/values.yaml

# Commit and push changes
git commit -am "Update application configuration"
git push

# ArgoCD will automatically detect and apply changes
```

## Scaling the Application

Manually scale your deployment:

```bash
# Scale to 5 replicas
kubectl scale deployment boardgame --replicas=5

# Or update the HPA configuration
kubectl edit hpa boardgame
```

## Monitoring and Logging

The deployment can be integrated with:

- **Prometheus**: For application and cluster metrics collection
- **Grafana**: For metrics visualization and dashboards
- **Loki**: For log aggregation and search
- **Jaeger/Zipkin**: For distributed tracing

## Troubleshooting

### Common Issues

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

### Common ArgoCD Issues

- **Application Not Syncing**: Check network connectivity to Git repository and authentication
- **Out of Sync Status**: Manually review differences in ArgoCD UI
- **Image Not Updating**: Verify that the image exists in Docker Hub with the correct tag
- **Permission Issues**: Check RBAC settings for ArgoCD service account

## Next Steps

Now that you've deployed your application to Kubernetes with ArgoCD:

1. Set up monitoring and observability for your application
2. Proceed to the [Monitoring directory](../Monitoring/) to configure Prometheus and Grafana
3. Create dashboards to visualize application metrics and health
4. Set up alerts for critical service conditions

For application details, check out the [BoardGame application directory](../BoardGame/) to understand the application structure and features.