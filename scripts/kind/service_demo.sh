#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../" && pwd)"
cd "$ROOT"

echo "Services:"
kubectl get svc

echo "Endpoints:"
kubectl get endpoints pdf-extractor-backend -o wide || true
kubectl get endpoints pdf-extractor-frontend -o wide || true

echo "Pods (backend/frontend):"
kubectl get pods -l app=pdf-extractor-backend -o wide || true
kubectl get pods -l app=pdf-extractor-frontend -o wide || true

echo "Curl services from ephemeral pod inside cluster"
kubectl run --rm --restart=Never --image=curlimages/curl curltest -- /bin/sh -c "echo BACKEND; curl -sS -D - http://pdf-extractor-backend:8000/health || true; echo; echo FRONTEND; curl -sS -D - http://pdf-extractor-frontend:80/ || true"

echo "NodePort access (frontend) - node IPs:"
kubectl get nodes -o wide

echo "Demo finished"
