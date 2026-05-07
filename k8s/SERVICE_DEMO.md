# Service demo: ClusterIP vs NodePort and routing to Pods

This demo shows how Kubernetes `Service` objects provide stable networking to Pods and route traffic using labels/selectors.

Files involved
- `k8s/backend-service.yaml` — `ClusterIP` Service for backend (port 8000 -> targetPort 8000)
- `k8s/frontend-service.yaml` — `NodePort` Service for frontend (port 80 -> targetPort 3000, nodePort 30080)

Key concepts
- Pods are ephemeral and get dynamic IPs; Services provide a stable virtual IP (ClusterIP) and DNS name to reach the set of Pods matching the Service selector.
- `ClusterIP` is only reachable inside the cluster (DNS name `pdf-extractor-backend` resolves to the ClusterIP).
- `NodePort` exposes the Service on each node at `nodePort` so external clients can reach the Service via `<nodeIP>:<nodePort>`.
- Services route traffic to Pods by matching the Service `selector` to Pod labels.

Demo steps (commands you can run locally)

1. Inspect Services and Endpoints
```bash
kubectl get svc
kubectl describe svc pdf-extractor-backend
kubectl describe svc pdf-extractor-frontend
kubectl get endpoints pdf-extractor-backend
kubectl get endpoints pdf-extractor-frontend
```

2. Verify backend reachable from inside cluster (ClusterIP)
```bash
kubectl run --rm --restart=Never --image=curlimages/curl curltest -- /bin/sh -c "echo 'BACKEND'; curl -sS -D - http://pdf-extractor-backend:8000/health || true; echo; echo 'FRONTEND'; curl -sS -D - http://pdf-extractor-frontend:80/ || true"
```
This runs a temporary pod that resolves the Service DNS names and curls the backend `health` endpoint and the frontend root.

3. Access frontend externally via NodePort (from your host)
- If running on Docker Desktop or a cloud node, open `http://<node-ip>:30080` (node IP from `kubectl get nodes -o wide`).
- Or port-forward the frontend service to localhost:
```bash
kubectl port-forward svc/pdf-extractor-frontend 3000:80 &
# then open http://localhost:3000
```

4. Show how Services map to Pods and endpoints
```bash
kubectl get pods -l app=pdf-extractor-backend -o wide
kubectl get pods -l app=pdf-extractor-frontend -o wide
kubectl get endpoints pdf-extractor-backend -o yaml
```

5. Test selector mismatch (safety demo)
- If you change the Service selector so it doesn't match any Pod labels, `endpoints` will be empty and traffic won't be routed.

6. Cleanup (if needed)
```bash
# nothing to delete; this uses existing services
```

Interpretation (what to capture in PR)
- `kubectl get svc` + `kubectl get endpoints` shows how Services map to Pod IPs.
- The `curl` from inside cluster proves `ClusterIP` routing works even though Pods have dynamic IPs.
- The `NodePort` or port-forward shows external access options for the frontend.

