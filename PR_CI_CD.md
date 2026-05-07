Title: Add GitHub Actions CI/CD workflow (build/push + deploy)

Summary
- Adds `.github/workflows/ci-cd.yaml` which builds backend and frontend images and pushes them to GHCR, then deploys `k8s/` manifests and updates Deployment images.
- Adds `k8s/CI_README.md` with instructions for required secrets and how to run the pipeline.

Why this change
- Automates image build and deployment so merges to `main` trigger a reproducible deploy pipeline.

Secrets required for reviewers
- `KUBE_CONFIG_DATA` (base64 kubeconfig) — used by deploy job

How to verify
- Create a test branch and push. The workflow validates builds on PR and pushes images for `main`.
- For a full deploy: push to `main` with `KUBE_CONFIG_DATA` configured and watch the Actions run and `kubectl get pods` to confirm rollouts.

Notes
- This workflow uses GitHub Container Registry by default; update to Docker Hub or other registries if required.
