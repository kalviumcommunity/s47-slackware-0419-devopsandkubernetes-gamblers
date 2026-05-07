#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME=${1:-pdf-extractor-kind}
KIND_CONFIG=${2:-k8s/kind-config.yaml}
REGISTRY_NAME="kind-registry"
REGISTRY_PORT="5000"

# Check dependencies
command -v kind >/dev/null 2>&1 || { echo "kind not found. Install https://kind.sigs.k8s.io"; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "docker not found. Install Docker Desktop or docker."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "kubectl not found. Install kubectl."; exit 1; }

# Create local registry if not running
if [ "$(docker ps -q -f name=${REGISTRY_NAME})" = "" ]; then
  echo "Starting local registry ${REGISTRY_NAME}:${REGISTRY_PORT}"
  docker run -d --restart=always -p "${REGISTRY_PORT}:5000" --name "${REGISTRY_NAME}" registry:2
else
  echo "Local registry ${REGISTRY_NAME} already running"
fi

# Create kind cluster
echo "Creating kind cluster ${CLUSTER_NAME} with config ${KIND_CONFIG}"
kind create cluster --name "${CLUSTER_NAME}" --config "${KIND_CONFIG}"

# Connect the registry to the kind network
KIND_NET="kind"
if docker network ls | grep -q ${KIND_NET}; then
  docker network connect ${KIND_NET} ${REGISTRY_NAME} || true
fi

# Configure registry in cluster (advertise to cluster users)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:5000"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF

echo "Cluster ${CLUSTER_NAME} created. Verify with 'kubectl cluster-info --context kind-${CLUSTER_NAME}' and 'kubectl get nodes'"
