#!/bin/bash
set -e

EXPECTED_VERSION=$(grep '"version"' devcontainer-feature.json | sed -E 's/.*"([^"]+)".*/\1/')
echo "🔧 Installing OpenFactory OPC UA Connector feature feature v${EXPECTED_VERSION} ..."

# Check compatibility of versions
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

echo "📁 Copying OPC UA Connector files..."
mkdir -p "/usr/local/share/openfactory-opcua"
cp -r "$(dirname "$0")/assets/." "/usr/local/share/openfactory-opcua"

# Set environment variables
echo "🛠️ Setting environment variables..."

# Capture version from feature options (install-time)
echo "export OPCUA_GATEWAY_VERSION=\"${OPCUA_GATEWAY_VERSION}\"" > /etc/profile.d/00-openfactory-opcua.sh
echo "export OPCUA_COORDINATOR_VERSION=\"${OPCUA_COORDINATOR_VERSION}\"" >> /etc/profile.d/00-openfactory-opcua.sh

# Append runtime-dependent variables
cat << 'EOF' >> /etc/profile.d/00-openfactory-opcua.sh
CONTAINER_IP=$(hostname -I | awk '{print $1}')
export OPCUA_CONNECTOR_COORDINATOR="http://${CONTAINER_IP}:${COORDINATOR_PORT:-8000}"
EOF

chmod +x /etc/profile.d/00-openfactory-opcua.sh

# Set aliases
echo "🛠️ Adding helpful aliases to /etc/bash.bashrc..."
{
  echo '# OPC UA Connector feature aliases'
  echo 'alias opcua-connector-up="docker compose -f /usr/local/share/openfactory-opcua/docker-compose.yml up -d"'
  echo 'alias opcua-connector-down="docker compose -f /usr/local/share/openfactory-opcua/docker-compose.yml down"'
} >> /etc/bash.bashrc

echo "✅ OpenFactory OPC UA Connector feature setup complete."
