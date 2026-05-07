#!/usr/bin/env bash
set -euo pipefail

# Demo script: apply workload manifests and show desired-state behavior
ROOT="$(cd "$(dirname "$0")/../../" && pwd)"
cd "$ROOT"

echo "Applying standalone Pod"
kubectl apply -f k8s/pod-example.yaml
kubectl wait --for=condition=Ready pod/standalone-nginx --timeout=120s || true
kubectl get pod standalone-nginx -o wide

echo "Applying ReplicaSet"
kubectl apply -f k8s/replicaset-example.yaml
sleep 3
kubectl get rs nginx-replicaset-demo
kubectl get pods -l app=nginx-rs-demo -o wide

echo "Deleting ReplicaSet pods to show controller recreates them"
kubectl delete pod -l app=nginx-rs-demo --ignore-not-found
sleep 5
kubectl get pods -l app=nginx-rs-demo -o wide

echo "Deleting standalone Pod (should not be recreated)"
kubectl delete pod standalone-nginx --ignore-not-found
kubectl get pod standalone-nginx --ignore-not-found || true

echo "Scaling ReplicaSet to 5 replicas"
kubectl scale rs nginx-replicaset-demo --replicas=5 || true
sleep 5
kubectl get rs nginx-replicaset-demo
kubectl get pods -l app=nginx-rs-demo -o wide

echo "Cleanup"
#kubectl delete -f k8s/replicaset-example.yaml
#kubectl delete -f k8s/pod-example.yaml

echo "Demo finished"
