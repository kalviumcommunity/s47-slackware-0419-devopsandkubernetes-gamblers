# Workload demo: Pod vs ReplicaSet (desired-state)

This file demonstrates how Kubernetes desired-state management works using a standalone Pod and a ReplicaSet that manages multiple replicas.

Files
- `k8s/pod-example.yaml` — standalone Pod (named `standalone-nginx`)
- `k8s/replicaset-example.yaml` — ReplicaSet (`nginx-replicaset-demo`) with `replicas: 3`

Concepts (brief)
- Pod: the smallest deployable unit in Kubernetes. A Pod is a group of one or more containers that share resources and network. Pods created directly are not managed by controllers; if deleted they are gone.
- ReplicaSet: a controller that ensures a specified number of Pod replicas are running. If a Pod created by a ReplicaSet is deleted, the ReplicaSet will create a new Pod to match the `replicas` value.
- YAML: Kubernetes objects are declared in YAML files which describe the desired state. The control plane reconciles actual state toward that desired state.

Demo steps (run in repo root with `kubectl` and the Kind cluster context active):

1. Apply the standalone Pod
```bash
kubectl apply -f k8s/pod-example.yaml
kubectl wait --for=condition=Ready pod/standalone-nginx --timeout=120s
kubectl get pod standalone-nginx -o wide
```

2. Apply the ReplicaSet
```bash
kubectl apply -f k8s/replicaset-example.yaml
# wait for replicaset pods to be ready (may take seconds)
kubectl wait --for=condition=Ready pod -l app=nginx-rs-demo --timeout=120s || true
kubectl get rs nginx-replicaset-demo
kubectl get pods -l app=nginx-rs-demo -o wide
```

3. Demonstrate desired-state reconciliation: delete a ReplicaSet pod
```bash
# delete all replicaset pods (to show RS will recreate them)
kubectl delete pod -l app=nginx-rs-demo
# wait a few seconds, then list pods again
sleep 5
kubectl get pods -l app=nginx-rs-demo -o wide
```
You should see the ReplicaSet recreate pods until the desired `replicas: 3` is met.

4. Demonstrate deletion of a standalone Pod (no controller)
```bash
kubectl delete pod standalone-nginx || true
# Pod should be gone and will not be recreated
kubectl get pod standalone-nginx --ignore-not-found
```

5. Scale ReplicaSet (change desired state)
```bash
kubectl scale rs nginx-replicaset-demo --replicas=5
kubectl get rs nginx-replicaset-demo
kubectl wait --for=condition=Ready pod -l app=nginx-rs-demo --timeout=120s || true
kubectl get pods -l app=nginx-rs-demo -o wide
```

6. Cleanup
```bash
kubectl delete -f k8s/replicaset-example.yaml
kubectl delete -f k8s/pod-example.yaml
```

Notes
- These examples use `nginx:1.25-alpine` for a lightweight HTTP server. Replace images with your app images when testing in your project cluster.
- The ReplicaSet `selector.matchLabels` must match the Pod template labels; otherwise the ReplicaSet won't manage the pods.

Expected learning outcomes
- Observe that deleting a Pod created directly removes it permanently.
- Observe that deleting pods managed by a ReplicaSet triggers the controller to create replacements until the desired replica count is reached.
- Understand the role of YAML declarations as the desired state that the control plane reconciles.
