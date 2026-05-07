# Service demo run output

Collected outputs showing Services, Endpoints, Pods, and in-cluster HTTP requests proving Service routing.

## kubectl get svc -o wide

NAME                     TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE     SELECTOR
kubernetes               ClusterIP   10.96.0.1     <none>        443/TCP        2d22h   <none>
pdf-extractor-backend    ClusterIP   10.96.91.70   <none>        8000/TCP       3h17m   app=pdf-extractor-backend
pdf-extractor-frontend   NodePort    10.96.78.75   <none>        80:30080/TCP   2m1s    app=pdf-extractor-frontend

## kubectl get endpoints -o wide

NAME                     ENDPOINTS                         AGE
kubernetes               172.18.0.2:6443                   2d22h
pdf-extractor-backend    10.244.0.5:8000,10.244.0.6:8000   3h17m
pdf-extractor-frontend   10.244.0.7:3000                   2m1s

## kubectl get pods -o wide

NAME                                          READY   STATUS             RESTARTS   AGE     IP            NODE                    NOMINATED NODE   READINESS GATES
pdf-extractor-backend-786565d44c-7mc4g        1/1     Running            0          3h17m   10.244.0.6    desktop-control-plane   <none>           <none>
pdf-extractor-backend-786565d44c-sppdc        1/1     Running            0          3h17m   10.244.0.5    desktop-control-plane   <none>           <none>
pdf-extractor-backend-9799b9f97-4hzxj         0/1     ImagePullBackOff   0          28m     10.244.0.15   desktop-control-plane   <none>           <none>
pdf-extractor-backend-demo-548b856df5-7bktv   1/1     Running            0          28m     10.244.0.16   desktop-control-plane   <none>           <none>
pdf-extractor-backend-demo-548b856df5-l4f69   1/1     Running            0          28m     10.244.0.18   desktop-control-plane   <none>           <none>
pdf-extractor-backend-demo-548b856df5-tnvtb   1/1     Running            0          27m     10.244.0.20   desktop-control-plane   <none>           <none>
pdf-extractor-frontend-5998c97c8-r4r58        1/1     Running            0          3h17m   10.244.0.7    desktop-control-plane   <none>           <none>

## In-cluster curl test output

BACKEND
HTTP/1.1 200 OK
date: Thu, 07 May 2026 07:55:48 GMT
server: uvicorn
content-length: 61
content-type: application/json

{"status":"healthy","timestamp":"2026-05-07T07:55:48.606898"}

FRONTEND
HTTP/1.1 200 OK
Content-Length: 478
Content-Disposition: inline; filename="index.html"
Accept-Ranges: bytes
ETag: "0be3ceee19f0b3e674e64afeafe9868eecc2266b"
Content-Type: text/html; charset=utf-8
Vary: Accept-Encoding
Date: Thu, 07 May 2026 07:55:48 GMT
Connection: keep-alive
Keep-Alive: timeout=5

<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>PDF Text Extractor</title>
    <script type="module" crossorigin src="/assets/index-I9_32Uns.js"></script>
    <link rel="stylesheet" crossorigin href="/assets/index-SXN_kQ8L.css">
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>
