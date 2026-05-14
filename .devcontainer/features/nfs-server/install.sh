#!/bin/bash
set -e

EXPECTED_VERSION=$(grep '"version"' devcontainer-feature.json | sed -E 's/.*"([^"]+)".*/\1/')

echo "🔧 Installing OpenFactory NFS Server feature v${EXPECTED_VERSION} ..."

# -----------------------------------------------------------------------------
# Check compatibility of OpenFactory feature versions
# -----------------------------------------------------------------------------

if [ -f /usr/local/etc/openfactory_version ]; then
    INSTALLED_VERSION=$(cat /usr/local/etc/openfactory_version)

    if [ "$INSTALLED_VERSION" != "$EXPECTED_VERSION" ]; then
        echo "❌ OpenFactory features version mismatch"
        echo "Installed: $INSTALLED_VERSION"
        echo "Current:   $EXPECTED_VERSION"
        exit 1
    fi
fi

echo "$EXPECTED_VERSION" > /usr/local/etc/openfactory_version

# -----------------------------------------------------------------------------
# Copy feature assets
# -----------------------------------------------------------------------------

echo "📁 Copying OpenFactory NFS Server files..."

mkdir -p "/usr/local/share/openfactory-nfs"
cp -r "$(dirname "$0")/assets/." "/usr/local/share/openfactory-nfs"
chmod +x /usr/local/share/openfactory-nfs/start-nfs.sh
chmod +x /usr/local/share/openfactory-nfs/stop-nfs.sh

# -----------------------------------------------------------------------------
# Install helper commands
# -----------------------------------------------------------------------------

echo "🛠️ Installing helper commands..."

ln -sf \
    /usr/local/share/openfactory-nfs/start-nfs.sh \
    /usr/local/bin/openfactory-start-nfs
ln -sf \
    /usr/local/share/openfactory-nfs/stop-nfs.sh \
    /usr/local/bin/openfactory-stop-nfs

# -----------------------------------------------------------------------------
# Export environment variables
# -----------------------------------------------------------------------------

echo "🛠️ Setting environment variables..."

cat << EOF > /etc/profile.d/00-openfactory-nfs.sh
export NFS_UID="${NFS_UID}"
export NFS_GID="${NFS_GID}"
export NFS_MOUNTPOINT="${NFS_MOUNTPOINT}"

export NFS_CONTAINER_NAME="devcontainer-nfs"
export NFS_VOLUME_NAME="devcontainer-nfsdata"
export NFS_NETWORK_NAME="factory-net"
EOF

chmod +x /etc/profile.d/00-openfactory-nfs.sh

# -----------------------------------------------------------------------------
# Add helpful aliases
# -----------------------------------------------------------------------------

echo "🛠️ Adding helpful aliases to /etc/bash.bashrc..."

{
  echo '# OpenFactory NFS feature aliases'
  echo 'alias nfs-start="openfactory-start-nfs"'
  echo 'alias nfs-stop="openfactory-stop-nfs"'
} >> /etc/bash.bashrc

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------

echo "✅ OpenFactory NFS Server feature setup complete."
echo
echo "Run:"
echo
echo "  openfactory-start-nfs"
echo
echo "to start the mocked NFS server."
