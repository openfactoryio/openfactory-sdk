#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# OpenFactory Mocked NFS Server
#
# Starts (or reuses) a mocked NFS server container suitable for the
# OpenFactory SDK.
#
# Required environment variables:
#
#   NFS_UID
#   NFS_GID
#   NFS_MOUNTPOINT
#
# -----------------------------------------------------------------------------

NFS_CONTAINER_NAME="devcontainer-nfs"
NFS_VOLUME_NAME="devcontainer-nfsdata"
NFS_NETWORK_NAME="factory-net"

echo "⚙️  Starting OpenFactory mocked NFS server..."
echo "    NFS mountpoint : ${NFS_MOUNTPOINT}"
echo "    NFS UID:GID    : ${NFS_UID}:${NFS_GID}"

# -----------------------------------------------------------------------------
# Validate environment
# -----------------------------------------------------------------------------

if ! command -v docker >/dev/null 2>&1; then
    echo "❌ Docker is required but was not found."
    exit 1
fi

if [ -z "${NFS_UID:-}" ]; then
    echo "❌ NFS_UID is not set."
    exit 1
fi

if [ -z "${NFS_GID:-}" ]; then
    echo "❌ NFS_GID is not set."
    exit 1
fi

if [ -z "${NFS_MOUNTPOINT:-}" ]; then
    echo "❌ NFS_MOUNTPOINT is not set."
    exit 1
fi

# -----------------------------------------------------------------------------
# Create network if needed
# -----------------------------------------------------------------------------

echo "🔍 Checking Docker network '${NFS_NETWORK_NAME}'..."

if ! docker network inspect "${NFS_NETWORK_NAME}" >/dev/null 2>&1; then
    echo "🔗 Creating Docker network '${NFS_NETWORK_NAME}'..."

    docker network create \
        --driver bridge \
        --label com.docker.compose.network="${NFS_NETWORK_NAME}" \
        "${NFS_NETWORK_NAME}"
else
    echo "✅ Network already exists."
fi

# -----------------------------------------------------------------------------
# Create persistent volume if needed
# -----------------------------------------------------------------------------

echo "🔍 Checking Docker volume '${NFS_VOLUME_NAME}'..."

if ! docker volume inspect "${NFS_VOLUME_NAME}" >/dev/null 2>&1; then
    echo "📦 Creating Docker volume '${NFS_VOLUME_NAME}'..."
    docker volume create "${NFS_VOLUME_NAME}"
else
    echo "✅ Volume already exists."
fi

# -----------------------------------------------------------------------------
# Create or start NFS container
# -----------------------------------------------------------------------------

echo "🔍 Checking NFS server container '${NFS_CONTAINER_NAME}'..."

if ! docker ps -a --format '{{.Names}}' | grep -q "^${NFS_CONTAINER_NAME}$"; then

    echo "🚀 Creating NFS server container..."

    docker run -d \
        --name "${NFS_CONTAINER_NAME}" \
        --privileged \
        -e SHARED_DIRECTORY=/exports \
        -e ANONUID="${NFS_UID}" \
        -e ANONGID="${NFS_GID}" \
        -v "${NFS_VOLUME_NAME}:/exports" \
        -p 111:111/tcp \
        -p 111:111/udp \
        -p 2049:2049/tcp \
        -p 2049:2049/udp \
        --network "${NFS_NETWORK_NAME}" \
        --restart unless-stopped \
        itsthenetwork/nfs-server-alpine

else
    echo "▶ NFS server container already exists."

    if ! docker ps --format '{{.Names}}' | grep -q "^${NFS_CONTAINER_NAME}$"; then
        echo "🚀 Starting existing NFS server container..."
        docker start "${NFS_CONTAINER_NAME}" >/dev/null
    else
        echo "✅ NFS server container already running."
    fi
fi

# -----------------------------------------------------------------------------
# Prepare exported directory
# -----------------------------------------------------------------------------

EXPORT_PATH="/exports${NFS_MOUNTPOINT}"

echo "📁 Preparing exported directory '${EXPORT_PATH}'..."

docker exec "${NFS_CONTAINER_NAME}" sh -c "
    mkdir -p '${EXPORT_PATH}/.mocked_nfs' && \
    chown -R ${NFS_UID}:${NFS_GID} /exports && \
    chmod -R 755 /exports
"

# -----------------------------------------------------------------------------
# Print usage information
# -----------------------------------------------------------------------------

CONTAINER_IP="$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "${NFS_CONTAINER_NAME}")"

echo
echo "✅ OpenFactory mocked NFS server is ready."
echo
echo "NFS server name          : ${NFS_CONTAINER_NAME} (\$NFS_CONTAINER_NAME)"
echo "NFS export path          : ${NFS_MOUNTPOINT} (\$NFS_MOUNTPOINT)"
echo "NFS server IP            : ${CONTAINER_IP} (\$CONTAINER_IP)"
echo "NFS mountpoint owner UID : ${NFS_UID} (\$NFS_UID)"
echo "NFS mountpoint owner GID : ${NFS_GID} (\$NFS_GID)"
echo
echo "⚠️  Applications accessing this NFS export should typically run with:"
echo
echo "    UID=${NFS_UID}"
echo "    GID=${NFS_GID}"
echo
echo "Mount with:"
echo
echo "  sudo mount -t nfs ${CONTAINER_IP}:${NFS_MOUNTPOINT} /your/local/mountpoint"
echo
