Param()

$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
$repoRoot = Resolve-Path (Join-Path $scriptDir '..\..')
$manifestPath = Join-Path $repoRoot 'k8s\backend-deployment-demo.yaml'

Write-Output "Applying demo Deployment"
kubectl apply -f $manifestPath | Out-Null
kubectl rollout status deployment/pdf-extractor-backend-demo --timeout=120s
kubectl get deployment pdf-extractor-backend-demo -o wide
kubectl get pods -l app=pdf-extractor-backend-demo -o wide

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
