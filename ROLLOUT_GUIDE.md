# Rolling Updates and Rollbacks Guide

This guide demonstrates how to manage application updates safely with zero downtime and how to recover from failed deployments.

## 1. Triggering a Rolling Update

A rolling update is triggered whenever the Pod template in a Deployment is modified (e.g., changing the container image, environment variables, or labels).

### Scenario: Updating to a new version
Suppose you have built a new image `pdf-extractor-backend:v2`. You can update the deployment like this:

```bash
kubectl set image deployment/pdf-extractor-backend backend=pdf-extractor-backend:v2
```

### Monitoring the Progress
You can watch the rollout happen in real-time:
```bash
kubectl rollout status deployment/pdf-extractor-backend
```

---

## 2. Zero-Downtime Mechanics

Our deployment uses the following strategy to ensure the application stays online:
- **`maxSurge: 1`**: Kubernetes creates 1 extra pod before terminating an old one.
- **`maxUnavailable: 1`**: At most 1 pod is offline during the update.
- **Readiness Probes**: Crucially, Kubernetes will **not** terminate an old pod until the new pod's readiness probe returns success. This prevents traffic from being sent to a container that hasn't finished starting up.

---

## 3. Handling Failed Updates (The Rollback)

If you accidentally deploy a broken version (e.g., one that crashes or fails health checks), the rolling update will pause because the new pods will never become "Ready."

### Checking Rollout History
See a list of previous revisions:
```bash
kubectl rollout history deployment/pdf-extractor-backend
```

### Rolling Back to a Stable Version
To undo the last update and restore the previous stable version:
```bash
kubectl rollout undo deployment/pdf-extractor-backend
```

To roll back to a specific revision (e.g., revision 1):
```bash
kubectl rollout undo deployment/pdf-extractor-backend --to-revision=1
```

---

## 4. Evidence of Stability
During a rolling update, you can run a loop to verify zero downtime:
```bash
# In a separate terminal, watch the HTTP response codes
while true; do curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8000/health; sleep 1; done
```
You should see consistent `200` responses even as pods are being swapped out.
