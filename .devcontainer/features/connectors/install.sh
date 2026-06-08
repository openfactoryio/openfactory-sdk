#!/bin/bash
set -e

EXPECTED_VERSION=$(grep '"version"' devcontainer-feature.json | sed -E 's/.*"([^"]+)".*/\1/')
echo "🔧 Installing OpenFactory Connectors feature feature v${EXPECTED_VERSION} ..."

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
mkdir -p "/usr/local/share/openfactory-connectors"
cp -r "$(dirname "$0")/assets/." "/usr/local/share/openfactory-connectors"

# Set environment variables
echo "🛠️ Setting environment variables..."

# Capture version from feature options (install-time)
echo "export OPCUA_GATEWAY_VERSION=\"${OPCUA_GATEWAY_VERSION}\"" > /etc/profile.d/00-openfactory-connectors.sh
echo "export OPCUA_COORDINATOR_VERSION=\"${OPCUA_COORDINATOR_VERSION}\"" >> /etc/profile.d/00-openfactory-connectors.sh
echo "export SHDR_GATEWAY_VERSION=\"${SHDR_GATEWAY_VERSION}\"" >> /etc/profile.d/00-openfactory-connectors.sh
echo "export SHDR_COORDINATOR_VERSION=\"${SHDR_COORDINATOR_VERSION}\"" >> /etc/profile.d/00-openfactory-connectors.sh

chmod +x /etc/profile.d/00-openfactory-connectors.sh

# Set aliases
echo "🛠️ Adding helpful aliases to /etc/bash.bashrc..."
{
  echo '# OPC UA Connector feature aliases'
  echo 'alias opcua-connector-up="ofa apps up /usr/local/share/openfactory-connectors/app_opcua_connector.yml"'
  echo 'alias opcua-connector-down="ofa apps down /usr/local/share/openfactory-connectors/app_opcua_connector.yml"'
  echo '# SHDR Connector feature aliases'
  echo 'alias shdr-connector-up="ofa apps up /usr/local/share/openfactory-connectors/app_shdr_connector.yml"'
  echo 'alias shdr-connector-down="ofa apps down /usr/local/share/openfactory-connectors/app_shdr_connector.yml"'
} >> /etc/bash.bashrc

echo "✅ OpenFactory Connectors feature setup complete."
