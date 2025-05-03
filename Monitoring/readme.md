# Monitoring Setup for CI/CD Pipeline

This directory contains the configuration files necessary for setting up comprehensive monitoring of the CI/CD infrastructure and the deployed BoardGame application.

## Architecture Overview

The monitoring stack consists of the following components:

### 1. Application and Infrastructure Monitoring
- Prometheus for metrics collection and storage
- Blackbox Exporter for external HTTP endpoint monitoring
- Custom ServiceMonitor and Probe configurations for Prometheus Operator
- Jenkins metrics collection via the Prometheus plugin

### 2. Visualization and Alerting
- Grafana dashboards for visualization
- Alerting rules for critical service components
- Blackbox probes for uptime monitoring

## Configuration Files

### `blackbox-serviceMonitor.yaml`
This file configures Prometheus to scrape metrics from the Blackbox exporter, which performs HTTP probes against the application endpoints.

Key features:
- Configures Prometheus to collect metrics from Blackbox exporter
- Sets up relabeling to properly track target instances
- Specifies monitoring interval and endpoints

### `jenkins-scrapeConfig.yaml`
This file configures Prometheus to collect metrics from Jenkins via its Prometheus metrics plugin.

Key features:
- Sets up job label for Jenkins metrics
- Specifies the Jenkins endpoint to scrape metrics from
- Configures the metrics path for Jenkins Prometheus plugin

### `prope.yml`
This file defines a Prometheus Operator Probe resource that monitors the BoardGame application's HTTP endpoint.

Key features:
- Performs HTTP checks every 30 seconds
- Verifies that application endpoints return HTTP 2xx responses
- Integrates with the Blackbox exporter service

## Prerequisites

Before setting up monitoring, ensure you have:

1. A Kubernetes cluster with Prometheus Operator installed
   - The kube-prometheus-stack Helm chart is recommended
   - Blackbox exporter should be deployed

2. Jenkins with Prometheus metrics plugin installed
   - The plugin should be configured to expose metrics at /prometheus/

3. Access permissions to create Kubernetes resources in your namespace

## Deployment Instructions

### Step 1: Install Prometheus Stack (if not already installed)

```bash
# Add the Prometheus community Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install the kube-prometheus-stack
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --set grafana.adminPassword=your-secure-password
```

### Step 2: Install Blackbox Exporter

```bash
helm install blackbox-exporter prometheus-community/prometheus-blackbox-exporter \
  --set serviceMonitor.enabled=false
```

### Step 3: Apply Monitoring Configurations

```bash
# Apply the ServiceMonitor for Blackbox exporter
kubectl apply -f blackbox-serviceMonitor.yaml

# Apply the Probe configuration for the BoardGame application
kubectl apply -f prope.yml

# Apply the ScrapeConfig for Jenkins
kubectl apply -f jenkins-scrapeConfig.yaml
```

### Step 4: Accessing Monitoring Dashboards

After deployment, access Grafana to view your monitoring dashboards:

```bash
# Port-forward Grafana service
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
```

Then open your browser and navigate to http://localhost:3000. The default credentials are:
- Username: admin
- Password: the password configured during installation

## Configuring Grafana Dashboards

Once in Grafana, you can import pre-configured dashboards:

1. For Jenkins monitoring:
   - Dashboard ID: 9964 (Jenkins Performance and Health Overview)

2. For Application monitoring:
   - Dashboard ID: 13659 (Blackbox Exporter)

## Alerting Setup

To configure alerts based on metrics:

1. In Grafana, navigate to "Alerting" -> "Alert Rules" -> "New Alert Rule"
2. Configure alert conditions based on collected metrics
3. Set up notification channels (email, Slack, etc.) in "Alerting" -> "Contact Points"

## Troubleshooting

### Common Issues

1. **ServiceMonitor not working**:
   - Ensure labels match your Prometheus Operator selectors
   - Verify that the selector matchLabels match your Blackbox exporter labels
   - Check Prometheus logs for configuration errors

2. **Jenkins metrics not appearing**:
   - Verify Jenkins is accessible from the Prometheus pod
   - Check that the Jenkins Prometheus plugin is correctly installed
   - Ensure the metrics path is correctly configured

3. **Probe failures**:
   - Verify that the target services are running and accessible
   - Check Blackbox exporter logs for connection issues
   - Confirm service DNS resolution within the cluster

## Next Steps

Once your monitoring setup is complete:

1. Create custom Grafana dashboards for your specific metrics
2. Set up alerts for critical service metrics
3. Consider implementing distributed tracing with Jaeger or Zipkin 
4. Return to the [main README](../README.md) for a complete overview of the CI/CD pipeline