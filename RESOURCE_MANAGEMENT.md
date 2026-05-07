# Kubernetes Resource Management Guide

This document explains how this project manages CPU and Memory resources within a Kubernetes cluster to ensure stability, reliability, and efficient scheduling.

## 1. Resource Requests vs. Limits

In Kubernetes, there are two primary ways to specify container resources: **Requests** and **Limits**.

| Concept | Description | Analogy |
| :--- | :--- | :--- |
| **Requests** | The minimum amount of resources a container is guaranteed to have. | The "Rent": You are guaranteed this space. |
| **Limits** | The maximum amount of resources a container is allowed to consume. | The "Capacity": You cannot go beyond this, or you'll be evicted/throttled. |

### CPU Management
- **Requests**: Used by the `kube-scheduler` to find a node with enough available capacity. If a pod requests 250m CPU, it will only be placed on a node that has at least 250m unallocated CPU.
- **Limits**: Enforced by the CFS (Completely Fair Scheduler) quota in the Linux kernel. If a container reaches its CPU limit, it is **throttled** (slowed down) but not killed.

### Memory Management
- **Requests**: Guaranteed memory for the container.
- **Limits**: Hard cap. If a container exceeds its memory limit, the Linux kernel triggers an **OOM (Out Of Memory) Kill**, and Kubernetes will restart the container.

---

## 2. Scheduling Decisions

The `kube-scheduler` makes decisions based on the **sum of requests** of all pods already running on a node, not their actual usage.

- **Why this matters**: If you don't specify requests, Kubernetes assumes 0. This can lead to "Over-commitment," where too many pods are placed on one node, causing it to crash when they all start using resources simultaneously.
- **Our Strategy**: We set CPU requests to `250m` for the backend to ensure it has enough "breathing room" for PDF processing without competing with other critical system pods.

---

## 3. Preventing the "Noisy Neighbor" Problem

Unmanaged resource usage can destabilize an entire cluster. A "Noisy Neighbor" is a pod that consumes all available node resources (e.g., a memory leak or a recursive loop), starving other pods and potentially crashing the node.

- **How Limits Help**: By setting a CPU limit of `1000m` (1 core) and a Memory limit of `512Mi` for the backend, we ensure that even if the application malfunctions or receives a massive PDF, it cannot consume more than its "fair share."
- **Observable Stability**: Limits ensure that the `kube-apiserver`, `kubelet`, and other system components always have enough resources to keep the node healthy.

---

## 4. Implementation in this Project

### Backend (`k8s/backend-deployment.yaml`)
- **Reasoning**: PDF extraction is CPU-intensive (parsing text) and Memory-intensive (loading bytes into memory).
- **Values**: `250m/256Mi` (Requests) to guarantee performance; `1000m/512Mi` (Limits) to prevent runaway processes.

### Frontend (`k8s/frontend-deployment.yaml`)
- **Reasoning**: Nginx serving static React files is extremely efficient.
- **Values**: `50m/64Mi` (Requests) is plenty for baseline traffic; `100m/128Mi` (Limits) provides a small buffer for bursting without risk to the node.
