# CI/CD (GitHub Actions) — Setup & Secrets

This repository includes a GitHub Actions workflow: `.github/workflows/ci-cd.yaml` that builds backend and frontend Docker images, pushes them to GitHub Container Registry (GHCR), and deploys the `k8s/` manifests to a Kubernetes cluster.

Required repository secrets
- `KUBE_CONFIG_DATA` — base64-encoded kubeconfig for the target cluster (used by `kubectl`).
  - Linux/macOS:
    ```bash
    base64 -w0 $HOME/.kube/config
    ```
  - Windows PowerShell (recommended):
    ```powershell
    $bytes = Get-Content $HOME\.kube\config -Encoding Byte
    [System.Convert]::ToBase64String($bytes)
    ```
  Paste the resulting single-line base64 string into the repository secret `KUBE_CONFIG_DATA`.

Notes about image registry
- The workflow pushes images to GHCR at `ghcr.io/<owner>/pdf-extractor-backend:<sha>` and `ghcr.io/<owner>/pdf-extractor-frontend:<sha>` using the repository `GITHUB_TOKEN`.
- Ensure the repository permissions allow `packages: write` (the workflow already requests this permission).

How the deploy step works
1. The `build-and-push` job builds and pushes images to GHCR.
2. The `deploy` job writes `KUBE_CONFIG_DATA` to `$HOME/.kube/config`, applies all manifests in `k8s/`, then updates the `Deployment` images via `kubectl set image` and waits for rollouts.

If you prefer Docker Hub or another registry
- Replace the login and tags in `.github/workflows/ci-cd.yaml` or add secrets for `REGISTRY_USERNAME` and `REGISTRY_PASSWORD` and use them with `docker/login-action`.

Security
- Keep your kubeconfig secret and scoped to a service account with minimal permissions for CI deployments if possible.
