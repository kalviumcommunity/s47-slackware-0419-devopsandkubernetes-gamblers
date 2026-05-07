Title: Add Kind local-cluster setup scripts and docs

Summary
- Tool used: `kind` (Kubernetes IN Docker)
- Purpose: provide reproducible local Kubernetes cluster setup for development and testing of the pdf-extractor app, including a local registry and scripts for Windows/Linux.

What I added
- `k8s/kind-config.yaml` — Kind config enabling a local registry mirror and useful port mappings
- `scripts/kind/create_kind_cluster.sh` — Bash script to create a Kind cluster, start/connect local registry, and advertise it to the cluster
- `scripts/kind/create_kind_cluster.ps1` — PowerShell script with the same behavior for Windows
- `k8s/KIND_SETUP.md` — step-by-step usage and verification guide

How the cluster is created and verified
- Run `./scripts/kind/create_kind_cluster.sh` (Linux/macOS) or `.\scripts\kind\create_kind_cluster.ps1` (PowerShell)
- The script creates a `registry:2` container on `localhost:5000`, runs `kind create cluster --config k8s/kind-config.yaml`, and connects the registry to the Kind network.
- Verify with `kubectl cluster-info --context kind-pdf-extractor-kind` and `kubectl get nodes`.
- Build images locally and either `kind load docker-image <image> --name pdf-extractor-kind` or tag/push to `localhost:5000` and update deployment image names.
- Apply manifests and check `kubectl get pods`, `kubectl logs`, and `kubectl port-forward svc/pdf-extractor-backend 8000:8000` then `curl /health` to confirm the app responds.

How this supports the project
- Developers can reproduce a full cluster locally for testing deployments, probe configuration, networking, and readiness/liveness behavior.
- Local registry speeds image iteration without needing a remote registry.
- Documentation includes exact commands for loading images and applying the existing `k8s/` manifests in this repo.

Verification checklist to include in PR review
- [ ] Run the appropriate script to create the cluster
- [ ] Verify `kubectl get nodes` shows Kind nodes
- [ ] Build & load the backend image and apply manifests
- [ ] Confirm `curl http://localhost:8000/health` returns successful response via port-forward

Notes
- This change does not alter production manifests. It only adds development tooling and documentation.
- For CI or shared clusters, replace local registry usage with a real registry and secure credentials.
