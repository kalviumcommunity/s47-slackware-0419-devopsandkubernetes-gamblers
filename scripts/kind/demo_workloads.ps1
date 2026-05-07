Param()

$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Set-Location $root

Write-Output "Applying standalone Pod"
kubectl apply -f k8s/pod-example.yaml | Out-Null
kubectl wait --for=condition=Ready pod/standalone-nginx --timeout=120s 2>$null || Write-Output "wait timed out or pod not ready"
kubectl get pod standalone-nginx -o wide

Write-Output "Applying ReplicaSet"
kubectl apply -f k8s/replicaset-example.yaml | Out-Null
Start-Sleep -Seconds 3
kubectl get rs nginx-replicaset-demo
kubectl get pods -l app=nginx-rs-demo -o wide

Write-Output "Deleting ReplicaSet pods to show controller recreates them"
kubectl delete pod -l app=nginx-rs-demo --ignore-not-found
Start-Sleep -Seconds 5
kubectl get pods -l app=nginx-rs-demo -o wide

Write-Output "Deleting standalone Pod (should not be recreated)"
kubectl delete pod standalone-nginx --ignore-not-found
kubectl get pod standalone-nginx --ignore-not-found

Write-Output "Scaling ReplicaSet to 5 replicas"
kubectl scale rs nginx-replicaset-demo --replicas=5
Start-Sleep -Seconds 5
kubectl get rs nginx-replicaset-demo
kubectl get pods -l app=nginx-rs-demo -o wide

Write-Output "Demo finished"
