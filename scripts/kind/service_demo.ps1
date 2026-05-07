Param()

$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
$repoRoot = Resolve-Path (Join-Path $scriptDir '..\..')
Set-Location $repoRoot

Write-Output "Services:"
kubectl get svc

Write-Output "Endpoints:"
kubectl get endpoints pdf-extractor-backend -o wide 2>$null
kubectl get endpoints pdf-extractor-frontend -o wide 2>$null

Write-Output "Pods (backend/frontend):"
kubectl get pods -l app=pdf-extractor-backend -o wide 2>$null
kubectl get pods -l app=pdf-extractor-frontend -o wide 2>$null

Write-Output "Curl services from ephemeral pod inside cluster"
kubectl run --rm --restart=Never --image=curlimages/curl curltest -- /bin/sh -c "echo BACKEND; curl -sS -D - http://pdf-extractor-backend:8000/health || true; echo; echo FRONTEND; curl -sS -D - http://pdf-extractor-frontend:80/ || true"

Write-Output "NodePort access (frontend) - node IPs:"
kubectl get nodes -o wide

Write-Output "Demo finished"
