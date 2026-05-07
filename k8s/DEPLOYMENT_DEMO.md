# Deployment demo: declarative updates and rollouts

This document demonstrates using a Kubernetes `Deployment` to manage application lifecycle, perform declarative updates, observe rollouts, and undo changes.

Why Deployments
- Deployments provide declarative updates, ReplicaSet management, and rollout controls.
- They are preferred over directly creating Pods or managing ReplicaSets manually because Deployments handle rolling updates, history, and safe rollbacks.

Files used
- `k8s/backend-deployment.yaml` — Deployment for `pdf-extractor-backend` (3 replicas)

Demo steps
1. Apply the Deployment
```bash
kubectl apply -f k8s/backend-deployment.yaml
kubectl rollout status deployment/pdf-extractor-backend --timeout=120s
kubectl get deployment pdf-extractor-backend -o wide
kubectl get pods -l app=pdf-extractor-backend -o wide
```

2. Observe rollout history
```bash
kubectl rollout history deployment/pdf-extractor-backend
```

3. Perform a declarative update (change the container image)
```bash
kubectl set image deployment/pdf-extractor-backend backend=nginx:1.24-alpine --record
kubectl rollout status deployment/pdf-extractor-backend --timeout=120s
kubectl get pods -l app=pdf-extractor-backend -o wide
kubectl rollout history deployment/pdf-extractor-backend
```

4. Explain rollout behavior
- Kubernetes creates a new ReplicaSet for the updated Pod template and gradually replaces old replicas with new ones according to `strategy.rollingUpdate`.
- `kubectl rollout status` waits until the new ReplicaSet satisfies the desired replica count and readiness checks.
- `kubectl rollout history` shows revisions (useful for rollbacks).

5. Rollback to previous revision if needed
```bash
kubectl rollout undo deployment/pdf-extractor-backend
kubectl rollout status deployment/pdf-extractor-backend
```

6. Cleanup
```bash
kubectl delete -f k8s/backend-deployment.yaml
```

Notes
- This demo uses `nginx` as the running container to show rollout semantics. Replace the image with your app image (for example `localhost:5000/pdf-extractor-backend:dev`) when testing with your built images.
- The Deployment's `strategy` controls how many pods can be unavailable and how many extra pods can be created during updates (`maxUnavailable`/`maxSurge`).
