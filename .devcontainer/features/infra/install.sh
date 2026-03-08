#!/bin/bash
set -e

EXPECTED_VERSION=$(grep '"version"' devcontainer-feature.json | sed -E 's/.*"([^"]+)".*/\1/')
echo "🔧 Installing OpenFactory SDK feature v${EXPECTED_VERSION} ..."

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

echo "📁 Copying infrastructure files..."
mkdir -p "/usr/local/share/openfactory-sdk/openfactory-infra"
cp -r "$(dirname "$0")/assets/sdk-infra/." "/usr/local/share/openfactory-sdk/openfactory-infra/"

echo "📁 Copying helper scripts..."
for script in spinup.sh teardown.sh create_topics.sh topics.yml; do
  cp "$(dirname "$0")/assets/$script" /usr/local/bin/$script
  chmod +x /usr/local/bin/$script
done

# Install SDK
if [ "${USELOCALSDK}" = "true" ]; then
  echo "🐍 Using local SDK: skipping pip install in feature. Will install via postCreateCommand."
else
  echo "🐍 Installing OpenFactory-SDK from GitHub..."
  pip install --no-cache-dir --upgrade --force-reinstall \
    "git+https://github.com/openfactoryio/openfactory-sdk.git@${OPENFACTORY_VERSION}"
fi

# Install OpenFactory using OPENFACTORY_VERSION from the feature option
echo "🐍 Installing OpenFactory @${OPENFACTORY_VERSION} from GitHub..."
pip install --no-cache-dir --upgrade --force-reinstall \
  "git+https://github.com/openfactoryio/openfactory-core.git@${OPENFACTORY_VERSION}"

# Capture version from feature options (install-time)
if [ "${OPENFACTORY_VERSION}" = "main" ]; then
  EFFECTIVE_VERSION="latest"
else
  EFFECTIVE_VERSION="${OPENFACTORY_VERSION}"
fi

# Install fan-out-layer
echo "📁 Copying fan-out-layer files"
ofa templates copy fanoutlayer /usr/local/share/openfactory-sdk/openfactory-fanoutlayer/

# Write install-time variables
echo "export OPENFACTORY_VERSION=\"${OPENFACTORY_VERSION}\"" > /etc/profile.d/00-openfactory-sdk.sh
echo "export ASSET_FORWARDER_VERSION=\"${EFFECTIVE_VERSION}\"" >> /etc/profile.d/00-openfactory-sdk.sh
echo "export ASSET_ROUTER_VERSION=\"${EFFECTIVE_VERSION}\"" >> /etc/profile.d/00-openfactory-sdk.sh

# Append runtime-dependent variables
echo "🛠️ Setting container IP address and environment variables..."
cat << 'EOF' >> /etc/profile.d/00-openfactory-sdk.sh
CONTAINER_IP=$(ip -4 addr show eth0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || hostname -i | awk '{print $1}')
export CONTAINER_IP
export KAFKA_BROKER="${KAFKA_BROKER:-${CONTAINER_IP}:9092,broker:29092}"
export KSQLDB_URL="${KSQLDB_URL:-http://${CONTAINER_IP}:8088}"
export DEPLOYMENT_PLATFORM="docker"
export ASSET_ROUTER_URL="http://${CONTAINER_IP}:8002"
export NATS_CLUSTER_C1="nats://${CONTAINER_IP}:4222"
EOF

chmod +x /etc/profile.d/00-openfactory-sdk.sh

echo "🛠️ Adding helpful aliases to /etc/bash.bashrc..."
{
  echo '# OpenFactory-SDK aliases'
  echo 'alias ksql="docker exec -it ksqldb-cli ksql http://ksqldb-server:8088"'
  echo "alias spinup='/usr/local/bin/spinup.sh'"
  echo "alias teardown='/usr/local/bin/teardown.sh'"
} >> /etc/bash.bashrc

echo "✅ OpenFactory SDK setup complete."
