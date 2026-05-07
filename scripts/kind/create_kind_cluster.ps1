Param(
  [string]$ClusterName = "pdf-extractor-kind",
  [string]$KindConfig = "k8s/kind-config.yaml"
)

$registryName = "kind-registry"
$registryPort = 5000

if (-not (Get-Command kind -ErrorAction SilentlyContinue)) {
  Write-Error "kind CLI not found. Install: https://kind.sigs.k8s.io"
  exit 1
}
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Write-Error "docker not found. Install Docker Desktop or Docker Engine."
  exit 1
}
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
  Write-Error "kubectl not found. Install kubectl."
  exit 1
}

# Create registry if missing
$reg = docker ps -a --format "{{.Names}}" | Where-Object { $_ -eq $registryName }
if (-not $reg) {
  Write-Output ("Starting local registry {0}:{1}" -f $registryName, $registryPort)
  docker run -d --restart=always -p "$registryPort`:5000" --name $registryName registry:2 | Out-Null
} else {
  Write-Output ("Local registry {0} already exists" -f $registryName)
}

Write-Output "Creating kind cluster $ClusterName with config $KindConfig"
kind create cluster --name $ClusterName --config $KindConfig

# Connect registry to kind network
$kindNetwork = 'kind'
$networks = docker network ls --format "{{.Name}}"
if ($networks -contains $kindNetwork) {
  docker network connect $kindNetwork $registryName 2>$null | Out-Null
}

# Advertise local registry inside cluster
@"
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:5000"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
"@ | kubectl apply -f -

Write-Output "Done. Verify with: kubectl cluster-info --context kind-$ClusterName; kubectl get nodes"
