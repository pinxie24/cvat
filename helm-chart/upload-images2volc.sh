#!/bin/bash
# Upload CVAT images to Volcano Engine Container Registry

# Default values
REGISTRY="cr-demo-cn-shanghai.cr.volces.com"
NAMESPACE="cvat"
USERNAME=""
PASSWORD=""

# Display help information
show_help() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -r, --registry    Specify registry address (default: cr-demo-cn-shanghai.cr.volces.com)"
  echo "  -n, --namespace   Specify namespace (required)"
  echo "  -u, --username    Specify username (required unless VOLC_USERNAME is set)"
  echo "  -p, --password    Specify password (required unless VOLC_PASSWORD is set)"
  echo "  -h, --help        Display this help information"
  echo ""
  echo "Environment variables can also be used:"
  echo "  VOLC_REGISTRY   - Registry address"
  echo "  VOLC_NAMESPACE  - Namespace"
  echo "  VOLC_USERNAME   - Username"
  echo "  VOLC_PASSWORD   - Password"
  exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -r|--registry)
      REGISTRY="$2"
      shift 2
      ;;
    -n|--namespace)
      NAMESPACE="$2"
      shift 2
      ;;
    -u|--username)
      USERNAME="$2"
      shift 2
      ;;
    -p|--password)
      PASSWORD="$2"
      shift 2
      ;;
    -h|--help)
      show_help
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      ;;
  esac
done

# Check environment variables
REGISTRY=${VOLC_REGISTRY:-$REGISTRY}
NAMESPACE=${VOLC_NAMESPACE:-$NAMESPACE}
USERNAME=${VOLC_USERNAME:-$USERNAME}
PASSWORD=${VOLC_PASSWORD:-$PASSWORD}

# Validate required parameters
if [ -z "$NAMESPACE" ]; then
  echo "Error: Namespace must be specified"
  show_help
fi

if [ -z "$USERNAME" ]; then
  echo "Error: Username must be specified"
  show_help
fi

if [ -z "$PASSWORD" ]; then
  echo "Error: Password must be specified"
  show_help
fi

echo "Using the following configuration:"
echo "Registry: $REGISTRY"
echo "Namespace: $NAMESPACE"
echo "Username: $USERNAME"
echo "Password: ********"

# Login to Volcano Engine Container Registry
echo "Logging in to registry..."
echo "$PASSWORD" | docker login $REGISTRY -u $USERNAME --password-stdin

if [ $? -ne 0 ]; then
  echo "Login failed, please check your credentials"
  exit 1
fi

# Define image list
declare -A IMAGES=(

  ["traefik:v2.10"]="${REGISTRY}/${NAMESPACE}/traefik:v2.10"
  ["cvat/server:v2.31.0"]="${REGISTRY}/${NAMESPACE}/cvat-server:v2.31.0"
  ["docker.io/grafana/grafana:10.1.5"]="${REGISTRY}/${NAMESPACE}/grafana:10.1.5"
  ["docker.io/bitnami/clickhouse:23.12.2-debian-11-r0"]="${REGISTRY}/${NAMESPACE}/#clickhouse:23.12.2-debian-11-r0"
  ["docker.io/bitnami/postgresql:15.2.0-debian-11-r0"]="${REGISTRY}/${NAMESPACE}/postgresql:15.2.0-debian-11-r0"
  ["docker.io/bitnami/redis:7.2.3-debian-11-r1"]="${REGISTRY}/${NAMESPACE}/redis:7.2.3-debian-11-r1"
  ["timberio/vector:0.26.0-alpine"]="${REGISTRY}/${NAMESPACE}/vector:0.26.0-alpine"
  ["apache/kvrocks:2.7.0"]="${REGISTRY}/${NAMESPACE}/kvrocks:2.7.0"
  ["openpolicyagent/opa:0.63.0"]="${REGISTRY}/${NAMESPACE}/opa:0.63.0"
  ["busybox:latest"]="${REGISTRY}/${NAMESPACE}/busybox:latest"
  ["docker.io/bats/bats:v1.4.1"]="${REGISTRY}/${NAMESPACE}/bats:v1.4.1"
)

# Pull and upload images
echo "Starting image processing..."
for src in "${!IMAGES[@]}"; do
  dest=${IMAGES[$src]}
  echo "Processing: $src -> $dest"

  # Check if local image already exists
  if docker image inspect $src >/dev/null 2>&1; then
    echo "Image $src already exists locally, skipping pull"
  else
    echo "Pulling image $src..."
    docker pull $src
    if [ $? -ne 0 ]; then
      echo "Warning: Failed to pull $src, skipping this image"
      continue
    fi
  fi

  echo "Tagging image $src -> $dest"
  docker tag $src $dest

  echo "Pushing image $dest..."
  docker push $dest
  if [ $? -ne 0 ]; then
    echo "Error: Failed to push $dest"
  else
    echo "Success: $dest uploaded"
  fi

  echo "-----------------------------------"
done

echo "All images processed"
echo "Images have been uploaded to $REGISTRY/$NAMESPACE"

# Logout from registry
docker logout $REGISTRY