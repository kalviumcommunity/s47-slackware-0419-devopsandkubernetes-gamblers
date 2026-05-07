Param()

$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Set-Location $root

kubectl apply -f k8s/backend-deployment.yaml | Out-Null
Write-Output "Applying demo Deployment"
kubectl apply -f k8s/backend-deployment-demo.yaml | Out-Null
kubectl rollout status deployment/pdf-extractor-backend-demo --timeout=120s
kubectl get deployment pdf-extractor-backend-demo -o wide
kubectl get pods -l app=pdf-extractor-backend-demo -o wide

kubectl set image deployment/pdf-extractor-backend backend=nginx:1.24-alpine --record
Write-Output "Performing rolling update: set image to nginx:1.24-alpine"
kubectl set image deployment/pdf-extractor-backend-demo backend=nginx:1.24-alpine --record
kubectl rollout status deployment/pdf-extractor-backend-demo --timeout=120s
kubectl get pods -l app=pdf-extractor-backend-demo -o wide
kubectl rollout history deployment/pdf-extractor-backend-demo

kubectl rollout undo deployment/pdf-extractor-backend
Write-Output "Undoing rollout to previous revision"
kubectl rollout undo deployment/pdf-extractor-backend-demo
kubectl rollout status deployment/pdf-extractor-backend-demo --timeout=120s
kubectl get pods -l app=pdf-extractor-backend-demo -o wide

Write-Output "Demo finished"
