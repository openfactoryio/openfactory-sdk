#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# OpenFactory Mocked NFS Server
#
# Stops the mocked NFS server container used by the OpenFactory SDK
# and removes its persistent Docker volume.
#
# -----------------------------------------------------------------------------

NFS_CONTAINER_NAME="devcontainer-nfs"
NFS_VOLUME_NAME="devcontainer-nfsdata"

echo "🛑 Stopping OpenFactory mocked NFS server..."

# -----------------------------------------------------------------------------
# Validate environment
# -----------------------------------------------------------------------------

if ! command -v docker >/dev/null 2>&1; then
    echo "❌ Docker is required but was not found."
    exit 1
fi

# -----------------------------------------------------------------------------
# Stop container if it exists
# -----------------------------------------------------------------------------

if docker ps -a --format '{{.Names}}' | grep -q "^${NFS_CONTAINER_NAME}$"; then

    if docker ps --format '{{.Names}}' | grep -q "^${NFS_CONTAINER_NAME}$"; then
        echo "🛑 Stopping NFS server container '${NFS_CONTAINER_NAME}'..."
        docker stop "${NFS_CONTAINER_NAME}" >/dev/null
    else
        echo "ℹ️  NFS server container '${NFS_CONTAINER_NAME}' is already stopped."
    fi

    echo "🗑️  Removing NFS server container '${NFS_CONTAINER_NAME}'..."
    docker rm "${NFS_CONTAINER_NAME}" >/dev/null

else
    echo "ℹ️  NFS server container '${NFS_CONTAINER_NAME}' does not exist."
fi

# -----------------------------------------------------------------------------
# Remove persistent volume
# -----------------------------------------------------------------------------

if docker volume inspect "${NFS_VOLUME_NAME}" >/dev/null 2>&1; then
    echo "🗑️  Removing Docker volume '${NFS_VOLUME_NAME}'..."
    docker volume rm "${NFS_VOLUME_NAME}" >/dev/null

    echo "✅ Docker volume removed."
else
    echo "ℹ️  Docker volume '${NFS_VOLUME_NAME}' does not exist."
fi

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------

echo "✅ OpenFactory mocked NFS server cleanup complete."
