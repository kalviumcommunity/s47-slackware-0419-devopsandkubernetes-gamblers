# Scaling Guide: Manual and Automatic Scaling in Kubernetes

This guide explains how to scale the PDF Extractor application to handle fluctuations in traffic and processing demand.

## 1. Manual Scaling

Manual scaling is useful when you have a planned increase in load (e.g., a scheduled marketing event) or when you want to quickly add capacity.

### Method A: Imperative Scaling (Command Line)
You can use the `kubectl scale` command to immediately change the number of replicas:
```bash
# Scale up to 5 replicas
kubectl scale deployment/pdf-extractor-backend --replicas=5

# Scale down to 2 replicas
kubectl scale deployment/pdf-extractor-backend --replicas=2
```

### Method B: Declarative Scaling (YAML)
Modify the `replicas` field in `k8s/backend-deployment.yaml` and re-apply:
```yaml
spec:
  replicas: 5
```
Then run:
```bash
kubectl apply -f k8s/backend-deployment.yaml
```

---

## 2. Automatic Scaling (Horizontal Pod Autoscaler)

The **Horizontal Pod Autoscaler (HPA)** automatically scales the number of Pods in a deployment based on observed CPU/Memory utilization.

### How it works:
1. **Observation**: The HPA controller periodically queries the resource utilization metrics (via the Metrics Server).
2. **Calculation**: It calculates the ratio between current utilization and the desired target.
   - *Formula*: `DesiredReplicas = ceil[CurrentReplicas * (CurrentMetricValue / TargetMetricValue)]`
3. **Action**: If the calculated number of replicas differs from the current count, the HPA controller instructs the Deployment to scale up or down.

### Our Configuration (`k8s/backend-hpa.yaml`):
- **Min Replicas**: 2 (Ensures high availability even at low load).
- **Max Replicas**: 10 (Prevents infinite scaling/cost overrun).
- **Target CPU**: 70% (Triggers scale-up when the backend is consistently busy processing PDFs).
- **Target Memory**: 80% (Protects against memory-intensive processing).

---

## 3. Prerequisite: Metrics Server

For HPA to work, the cluster must have the **Metrics Server** installed. You can check if it's running with:
```bash
kubectl get pods -n kube-system | grep metrics-server
```
If you don't see it, you can install it on most local clusters (like Kind or Minikube) using:
```bash
# For Kind/Minikube
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```
*Note: In Kind, you may need to patch the metrics-server deployment to use `--kubelet-insecure-tls`.*

---

## 4. Why Scaling Matters
- **Availability**: More replicas mean the application can handle more concurrent users without failing.
- **Resilience**: If a node fails, having replicas spread across other nodes ensures the service remains online.
- **Efficiency**: Auto-scaling down during low-traffic periods (like nights) saves cloud costs.
