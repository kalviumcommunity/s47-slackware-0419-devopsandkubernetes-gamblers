# Kubernetes Integration Guide

This guide documents how this project maps to Kubernetes concepts and how to deploy and debug it locally.

Why Kubernetes (brief)
- Service discovery and DNS (services discover each other by name).
- Declarative deployment and rolling updates (Deployments handle rollouts and scaling).
- Health checks and self-healing (Readiness and Liveness probes).
- Resource quotas and limits (requests/limits help cluster scheduling).
- Config separation (ConfigMaps/Secrets for configuration and credentials).

What I added
- `k8s/configmap.yaml` — ConfigMap with runtime values (APP_ENV, APP_VERSION, VITE_API_URL)
- `k8s/backend-deployment.yaml` — Deployment for the FastAPI backend with readiness/liveness probes and resource limits
- `k8s/backend-service.yaml` — ClusterIP service for the backend
- `k8s/frontend-deployment.yaml` — Deployment for the React frontend container
- `k8s/frontend-service.yaml` — NodePort service to expose the frontend locally
- `k8s/ingress.yaml` — Optional Ingress routing (requires an ingress controller)

Quick local deployment notes (kind/minikube)

Prereqs: `kubectl`, and either `kind` or `minikube` installed.

1) Build docker images locally

# Backend
```bash
# from project root
docker build -t pdf-extractor-backend:dev .

# Frontend
docker build -t pdf-extractor-frontend:dev ./frontend
```

2) If using kind, load images into the cluster
```bash
kind load docker-image pdf-extractor-backend:dev
kind load docker-image pdf-extractor-frontend:dev
```
If using minikube, use `minikube image load` instead.

3) Apply manifests
```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml
```
Optional (if using an ingress controller):
```bash
kubectl apply -f k8s/ingress.yaml
```

4) Verify
```bash
kubectl get pods
kubectl get svc
kubectl describe deploy/pdf-extractor-backend
kubectl logs -l app=pdf-extractor-backend -c backend --tail=200
```

Port-forwarding (if not using NodePort or ingress)
```bash
kubectl port-forward svc/pdf-extractor-backend 8000:8000
# in another terminal
kubectl port-forward svc/pdf-extractor-frontend 3000:80
```

Debugging tips and common commands
- View logs: `kubectl logs deployment/pdf-extractor-backend -c backend`
- Exec into pod: `kubectl exec -it $(kubectl get pod -l app=pdf-extractor-backend -o jsonpath="{.items[0].metadata.name}") -- /bin/sh`
- Check events: `kubectl get events --sort-by=.metadata.creationTimestamp`
- Describe: `kubectl describe pod <pod-name>` to see init/container errors
- Check mounts and permissions: verify files are present inside container via `kubectl exec`

Why these manifests show Kubernetes thinking
- Liveness/readiness probes delegate health checks to the platform (Kubernetes can restart unhealthy containers).
- Resource requests/limits allow the scheduler to make placement decisions.
- ConfigMap demonstrates separation of configuration from code; secrets should be used for credentials.
- Services and (optional) Ingress show how to expose components and route traffic.

Notes for PR reviewers
- The images used in manifests are `pdf-extractor-backend:dev` and `pdf-extractor-frontend:dev`. In CI/CD, push proper images to a registry and update the manifests or use imagePullSecrets.
- The `k8s/ingress.yaml` requires an ingress controller (e.g., `nginx-ingress`). For local testing, use minikube/ kind instructions shown above.

Next steps (suggested)
- Add a `k8s/production/` folder with manifests referencing registry-hosted images and imagePullSecrets
- Create a Helm chart to templatize environment differences
- Add CI job to build and push images and run `kubectl apply --dry-run=client` as a validation step

