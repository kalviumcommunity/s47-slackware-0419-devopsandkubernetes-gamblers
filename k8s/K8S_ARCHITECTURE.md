# Kubernetes Cluster Architecture — Applied to PDF Text Extractor

This document explains how a Kubernetes cluster is structured and how the cluster's components interact in the context of this project. It maps control-plane and worker-node responsibilities to the manifests in `k8s/` and gives practical debugging and demonstration commands you can use for the assignment video and PR.

Files referenced
- `k8s/backend-deployment.yaml` — backend Deployment (replicas, probes, resource requests)
- `k8s/backend-service.yaml` — backend ClusterIP Service
- `k8s/frontend-deployment.yaml` — frontend Deployment
- `k8s/frontend-service.yaml` — frontend NodePort Service
- `k8s/configmap.yaml` — configuration carried by the cluster
- `k8s/ingress.yaml` — optional Ingress routing (requires ingress controller)

---

## High-level cluster picture

A Kubernetes cluster has two logical planes:

- Control plane (master): API Server, etcd, Scheduler, Controller Manager (and cloud-controller-manager when in cloud).
- Worker nodes: kubelet, container runtime (containerd/docker), kube-proxy, and the pod containers.

                                                +--------------+
                                                |  kubectl CLI |
                                                      |
                                                      v
                                        +------------------------------+
                                        |        API Server (kube-apiserver)
                                        +------------------------------+
                                           |          |          | 
           etcd <---- persistent state  <---+          |          +--- Scheduler
                                           |          |              (makes placement decisions)
                                           v          v
                                Controller Manager   Admission Controllers

                                  Worker Node A   Worker Node B
                                  -------------   -------------
    kubelet -> container runtime -> container   kubelet -> container runtime -> container
    kube-proxy -> iptables/ipvs -> service IP   kube-proxy -> iptables/ipvs -> service IP


## Control plane responsibilities (and how they apply)

- kube-apiserver
  - Central endpoint for all cluster state changes (`kubectl apply -f k8s/*.yaml`).
  - In our workflow, `kubectl apply` sends the `Deployment`/`Service` specs to the API server which persists them to `etcd` and answers queries from components.

- etcd
  - The authoritative store for cluster state (Deployments, Pods, Services, ConfigMaps). For this project etcd stores the `Deployment` and `Service` objects you apply.

- Controller Manager
  - Runs controllers (Deployment controller, ReplicaSet controller, Node controller). When you create `pdf-extractor-backend` Deployment, the Deployment controller ensures the correct ReplicaSet & Pod count exist.
  - If a Pod crashes, controllers reconcile (create new Pod) to match the declared state.

- Scheduler
  - Watches for unscheduled pods and assigns them to nodes based on resource requests/limits and node characteristics. `resources.requests` in `backend-deployment.yaml` help the scheduler choose nodes.

- Admission controllers
  - Enforce policies (for example PodSecurity, LimitRanger). In production these can block or mutate requests.

## Worker node responsibilities (and how they apply)

- kubelet
  - Watches the API server for pods scheduled to the node, pulls images via the container runtime, creates containers, executes liveness/readiness probes, reports status back to the API server.
  - Example: the `readinessProbe` in `backend-deployment.yaml` is executed by kubelet; only after it succeeds will the pod be included in the Service endpoints.

- Container runtime (containerd/docker)
  - Pulls and runs `pdf-extractor-backend:dev` and `pdf-extractor-frontend:dev` images. For local kind/minikube testing you must load images into the cluster or push to a registry.

- kube-proxy
  - Programmes networking rules (iptables/IPVS) so `Service` IPs route to healthy pod endpoints. When we query `pdf-extractor-backend` ClusterIP from other pods, kube-proxy performs the required forwarding.

- CNI plugin (Calico/Flannel/etc.)
  - Provides pod-to-pod networking across nodes. The app relies on pod networking for Service-to-pod connectivity.

## Request lifecycle for an applied manifest (concrete sequence)

1. `kubectl apply -f k8s/backend-deployment.yaml` -> request sent to kube-apiserver.
2. API server validates and stores Deployment object in etcd.
3. Deployment controller creates a ReplicaSet object and Pod templates in etcd.
4. Scheduler selects a node for each pod (based on `requests`, taints/tolerations, affinity).
5. kubelet on chosen node pulls image via container runtime and starts containers.
6. kubelet runs readiness probes; when successful the pod becomes `Ready`.
7. kube-proxy registers pod IP in the `Service` Endpoints; DNS (CoreDNS) resolves `pdf-extractor-backend` to ClusterIP.
8. Ingress/NodePort exposes frontend to external traffic which is routed to backend via Service (if appropriate).

This flow is useful to show step-by-step evidence in your demo video: show `kubectl get pods -w` to watch scheduling, then `kubectl logs` and `kubectl get endpoints` to show readiness and routing.

## Mapping manifest fields to cluster responsibilities

- `readinessProbe` and `livenessProbe` -> kubelet executes and reports health states used by controllers and kube-proxy (removes pod from endpoints if readiness fails).
- `resources.requests/limits` -> Scheduler uses `requests` to pack pods onto available nodes.
- `replicas` in Deployment -> Controller Manager ensures desired number of pods.
- `ClusterIP` Service -> kube-proxy and CoreDNS handle discovery and routing.
- `ConfigMap` -> stored in etcd, provided as environment variables into pods by kubelet when creating containers.

## Observability & debugging commands (practical, what to show in the demo)

- Check applied objects and status
  - `kubectl get all` — quick inventory
  - `kubectl get deployments,svc,rs,pods --namespace=default`
  - `kubectl describe deploy pdf-extractor-backend`

- Watch scheduling and pod creation
  - `kubectl get pods -o wide -w`
  - `kubectl describe pod <pod-name>` — look for `Events` (scheduling, image pull, container start errors)

- Check logs and container output
  - `kubectl logs <pod-name> -c backend` (or use label selector: `kubectl logs -l app=pdf-extractor-backend -c backend`)

- Verify service routing
  - `kubectl get endpoints pdf-extractor-backend -o yaml` — confirm that `endpoints` point to pod IPs
  - From a debug pod: `kubectl run -it --rm --image=busybox debug -- /bin/sh` then `wget -qO- http://pdf-extractor-backend:8000/health`

- Image problems
  - `kubectl describe pod <pod>` -> `ImagePullBackOff` reasons
  - Ensure image is available in cluster (use `kind load docker-image` or push to a registry)

- Permission / volume issues (relevant to our earlier mount/venv problem)
  - `kubectl exec -it <pod> -- ls -la /app` to validate files inside container
  - If a host mount overwrote a built venv, you will see missing files; avoid mounting production venvs or run with an init container to create the environment.

- Advanced debug tools
  - `kubectl debug` (ephemeral containers) to run a debugging container inside the pod's namespace
  - `kubectl port-forward svc/pdf-extractor-backend 8000:8000` to access the service locally without exposing NodePort

## Common failure modes (with fixes) — project-specific examples

- ImagePullBackOff
  - Cause: image tag `pdf-extractor-backend:dev` not present on node.
  - Fix: `docker build -t pdf-extractor-backend:dev .` then `kind load docker-image pdf-extractor-backend:dev` or push to registry and update manifest.

- CrashLoopBackOff / SyntaxError
  - Cause: application code error (we saw a syntax error when Flask remnants remained in `app.py`).
  - Fix: inspect logs `kubectl logs`, fix code, rebuild image, update deployment (`kubectl rollout restart deploy/<name>`).

- ModuleNotFoundError after mounting host directory (venv overwritten)
  - Cause: final image copied venv in `/opt/venv` but a host mount on `/app` hid those files, or the container ran as non-root and couldn't access mounts.
  - Fixes:
    - For local debugging use `docker-compose.override.yml` or run container as root (dev only).
    - For Kubernetes, avoid mounting host directories into production pods; build images with all dependencies baked in or use init containers to prepare environment.

- Readiness failing and Service has no endpoints
  - Cause: readinessProbe fails, kubelet keeps the pod out of endpoints.
  - Fix: `kubectl logs` to find error in app; correct health endpoint or probe thresholds.

## Demonstrating architecture in your PR/video (suggested script)

1. Show repository files: point to `k8s/` manifests and `K8S_GUIDE.md`.
2. Build backend and frontend images:
   ```bash
   docker build -t pdf-extractor-backend:dev .
   docker build -t pdf-extractor-frontend:dev ./frontend
   ```
3. Load images into cluster (`kind load docker-image` or push to registry).
4. Apply manifests and `kubectl get pods -w` to show scheduling and pod startup.
5. Show `kubectl describe pod` and `kubectl logs` to demonstrate how control-plane and worker nodes report state.
6. Demonstrate a failure (e.g., deliberately use a nonexistent image tag) then fix it (load image or change tag), showing controller auto-reconciliation.
7. Show `kubectl port-forward` and `curl /health` and the `curl -F 'file=@sample.pdf'` extraction working.
8. Reference `DOCKER_DEBUG.md` and `K8S_GUIDE.md` for the detailed reproduction steps included in the PR.

## Production readiness notes (what reviewers should check)

- Replace `:dev` images with registry-hosted, immutable tags in `k8s/production/` manifests.
- Use `imagePullSecrets` if images are private.
- Add PodDisruptionBudget, NetworkPolicies, and ResourceQuota enforcement.
- Store secrets in `Secret` objects (not in ConfigMaps) and enable RBAC policies.
- Run readiness/liveness probes tuned to your app's startup profile.

---

This file should be included in your PR to demonstrate practical understanding of how Kubernetes components collaborate to run, scale, and heal the application, and how to debug container lifecycle issues in the cluster. For a quick link to this doc see `k8s/K8S_ARCHITECTURE.md`.
