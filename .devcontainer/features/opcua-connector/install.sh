#!/bin/bash
set -e

echo "🔧 Installing OpenFactory OPC UA Connector feature ..."

echo "📁 Copying OPC UA Connector files..."
mkdir -p "/usr/local/share/openfactory-opcua"
cp -r "$(dirname "$0")/assets/." "/usr/local/share/openfactory-opcua"

# Set environment variables
echo "🛠️ Setting environment variables..."

# Capture version from feature options (install-time)
echo "export OPCUA_CONNECTOR_VERSION=\"${OPCUA_CONNECTOR_VERSION}\"" > /etc/profile.d/00-openfactory-opcua.sh

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
