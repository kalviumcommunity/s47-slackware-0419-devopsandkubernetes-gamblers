# Deployment demo run output

Collected outputs from running `scripts\kind\deployments_demo.ps1` on the local cluster (context: `docker-desktop`). This shows Deployment creation, ReplicaSet updates, rollout history, an attempted rolling update, and image-pull failures observed during the demo.

## kubectl get deployments -o wide

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES                       SELECTOR
pdf-extractor-backend        2/2     2            2           159m    backend      pdf-extractor-backend:dev    app=pdf-extractor-backend
pdf-extractor-backend-demo   0/3     2            0           7m24s   backend      nginx:1.25-alpine            app=pdf-extractor-backend-demo
pdf-extractor-frontend       1/1     1            1           159m    frontend     pdf-extractor-frontend:dev   app=pdf-extractor-frontend

## kubectl get rs -o wide

NAME                                    DESIRED   CURRENT   READY   AGE     CONTAINERS   IMAGES                       SELECTOR
pdf-extractor-backend-786565d44c        2         2         2       159m    backend      pdf-extractor-backend:dev    app=pdf-extractor-backend,pod-template-hash=786565d44c
pdf-extractor-backend-9799b9f97         0         0         0       9m42s   backend      nginx:1.24-alpine            app=pdf-extractor-backend,pod-template-hash=9799b9f97
pdf-extractor-backend-demo-548b856df5   2         2         0       8m7s    backend      nginx:1.25-alpine            app=pdf-extractor-backend-demo,pod-template-hash=548b856df5
pdf-extractor-backend-demo-7987b46bd    2         2         0       6m6s    backend      nginx:1.24-alpine            app=pdf-extractor-backend-demo,pod-template-hash=7987b46bd
pdf-extractor-frontend-5998c97c8        1         1         1       159m    frontend     pdf-extractor-frontend:dev   app=pdf-extractor-frontend,pod-template-hash=5998c97c8

## kubectl get pods -o wide

NAME                                          READY   STATUS             RESTARTS   AGE     IP            NODE                    NOMINATED NODE   READINESS GATES
pdf-extractor-backend-786565d44c-7mc4g        1/1     Running            0          160m    10.244.0.6    desktop-control-plane   <none>           <none>
pdf-extractor-backend-786565d44c-sppdc        1/1     Running            0          160m    10.244.0.5    desktop-control-plane   <none>           <none>
pdf-extractor-backend-demo-548b856df5-4z7js   0/1     ImagePullBackOff   0          8m15s   10.244.0.11   desktop-control-plane   <none>           <none>
pdf-extractor-backend-demo-548b856df5-5n8n5   0/1     ImagePullBackOff   0          8m15s   10.244.0.12   desktop-control-plane   <none>           <none>
pdf-extractor-backend-demo-7987b46bd-7n6rc    0/1     ImagePullBackOff   0          6m14s   10.244.0.13   desktop-control-plane   <none>           <none>
pdf-extractor-backend-demo-7987b46bd-wtf6l    0/1     ImagePullBackOff   0          6m14s   10.244.0.14   desktop-control-plane   <none>           <none>
pdf-extractor-frontend-5998c97c8-r4r58        1/1     Running            0          160m    10.244.0.7    desktop-control-plane   <none>           <none>

## kubectl describe pod pdf-extractor-backend-demo-548b856df5-4z7js (events)

Events:
  Type     Reason     Age                     From               Message
  ----     ------     ----                    ----               -------
  Normal   Scheduled  8m58s                   default-scheduler  Successfully assigned default/pdf-extractor-backend-demo-548b856df5-4z7js to desktop-control-plane
  Normal   Pulling    6m42s (x4 over 8m58s)   kubelet            Pulling image "nginx:1.25-alpine"
  Warning  Failed     6m32s (x4 over 8m43s)   kubelet            Failed to pull image "nginx:1.25-alpine": failed to pull and unpack image "docker.io/library/nginx:1.25-alpine": failed to read expected number of bytes: unexpected EOF
  Warning  Failed     6m32s (x4 over 8m43s)   kubelet            Error: ErrImagePull
  Warning  Failed     6m20s (x6 over 8m42s)   kubelet            Error: ImagePullBackOff
  Normal   BackOff    3m48s (x16 over 8m42s)  kubelet            Back-off pulling image "nginx:1.25-alpine"


---

Notes / interpretation
- The `Deployment` object and ReplicaSets were created successfully and Kubernetes attempted a rolling update when the image was changed.
- `kubectl set image` caused a new ReplicaSet to be created (revision 2 is recorded in the rollout history) and the controller attempted to bring new replicas up.
- Pods entered `ImagePullBackOff` due to failures pulling the `nginx:1.25-alpine` image (network/disk/registry truncation error shown as `unexpected EOF`). This prevented the rollout from completing.

Next steps to complete a successful demo on this machine:
- Ensure the cluster nodes can pull images from Docker Hub (network access), or
- Load the required images into the local node (for example, with `docker pull nginx:1.25-alpine` on the host and make it available to the cluster), or
- Use a local registry and tag/push the images there and update the Deployment image to the registry path.
