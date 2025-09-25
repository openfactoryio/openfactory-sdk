#!/bin/bash
set -e

echo "🔧 Installing OpenFactory OPC UA Connector feature ..."

echo "📁 Copying OPC UA Connector files..."
mkdir -p "/usr/local/share/openfactory-opcua"
cp -r "$(dirname "$0")/assets/." "/usr/local/share/openfactory-opcua"

# Install feature
if [ "${USELOCALSDK}" = "true" ]; then
  echo "🐍 Using local feature: skipping pip install in feature. Will install via postCreateCommand."
else
  echo "🐍 Installing OpenFactory OPC UA Connector feature from GitHub..."
  pip install --no-cache-dir --upgrade --force-reinstall \
    "git+https://github.com/openfactoryio/openfactory-sdk.git@${OPENFACTORY_VERSION}"
fi

# Set environment variables
echo "🛠️ Setting environment variables..."
cat << EOF > /etc/profile.d/00-openfactory-opcua.sh
export OPCUA_CONNECTOR_VERSION="${OPCUA_CONNECTOR_VERSION}"
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
