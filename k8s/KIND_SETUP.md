# Kind local cluster setup (pdf-extractor project)

This document shows how to create and verify a local Kubernetes cluster using Kind, and how to integrate it with this repository for development and testing.

Files added in this change
- `k8s/kind-config.yaml` — Kind cluster config (local registry mirror + port mappings)
- `scripts/kind/create_kind_cluster.sh` — Unix shell script to create cluster + registry
- `scripts/kind/create_kind_cluster.ps1` — PowerShell script for Windows
- `k8s/KIND_SETUP.md` — this document

Prerequisites
- Docker Desktop (or Docker Engine) installed and running
- `kind` CLI installed (https://kind.sigs.k8s.io)
- `kubectl` installed and configured in PATH

Quick steps (copy-paste)

- Create the cluster (Linux/macOS):
```bash
./scripts/kind/create_kind_cluster.sh
```
- Create the cluster (Windows PowerShell):
```powershell
.\.\scripts\kind\create_kind_cluster.ps1
```

What the scripts do
- Start a local `registry:2` container at `localhost:5000` (if missing).
- Create a Kind cluster using `k8s/kind-config.yaml` which instructs containerd to mirror `localhost:5000` to the registry container.
- Connect the registry container to the Kind network.
- Create a `kube-public` ConfigMap advertising the registry to cluster users.

Load project images into Kind
- Build the backend image locally and load it into kind (recommended):
```bash
# from repo root
docker build -t pdf-extractor-backend:dev .
kind load docker-image pdf-extractor-backend:dev --name pdf-extractor-kind

# frontend
docker build -t pdf-extractor-frontend:dev ./frontend
kind load docker-image pdf-extractor-frontend:dev --name pdf-extractor-kind
```

Or push to the local registry and use the `localhost:5000/...` image name:
```bash
docker tag pdf-extractor-backend:dev localhost:5000/pdf-extractor-backend:dev
docker push localhost:5000/pdf-extractor-backend:dev
# then in k8s/backend-deployment.yaml set image: localhost:5000/pdf-extractor-backend:dev
```

Apply the repository manifests
```bash
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml
```

Verify connectivity
```bash
# Check cluster
kubectl cluster-info --context kind-pdf-extractor-kind
kubectl get nodes
kubectl get pods -A

# Watch pods scheduling
kubectl get pods -w

# Port-forward backend and curl health
kubectl port-forward svc/pdf-extractor-backend 8000:8000 &
curl http://localhost:8000/health
```

Notes and troubleshooting
- If `kind load docker-image` is used, the image is loaded directly into nodes and no push is required.
- If you push to `localhost:5000`, make sure images in your manifests use `localhost:5000/...` and `imagePullPolicy: IfNotPresent`.
- If you see `ImagePullBackOff`, ensure the image is present in the cluster (use `docker images` and `kind load docker-image` or push to registry).

Suggested demo checklist (for PR / video)
- Run `./scripts/kind/create_kind_cluster.sh` (show output)
- Run `kubectl get nodes` and `kubectl get pods`
- Build & load backend image and apply manifests
- Show `kubectl logs` of backend pod and `kubectl port-forward` + `curl /health`

Security / production note
- This is for local development only. Do not use `localhost:5000` registry or open ports in production manifests.
