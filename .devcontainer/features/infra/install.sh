#!/bin/bash
set -e

echo "🔧 Installing OpenFactory SDK feature..."

echo "📁 Copying infrastructure files..."
mkdir -p "/usr/local/share/openfactory-sdk/openfactory-infra"
cp -r "$(dirname "$0")/assets/sdk-infra/." "/usr/local/share/openfactory-sdk/openfactory-infra/"

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

echo "🛠️ Setting container IP address and environment variables..."
cat << 'EOF' >> /etc/profile.d/00-openfactory-sdk.sh
CONTAINER_IP=$(ip -4 addr show eth0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || hostname -i | awk '{print $1}')
export CONTAINER_IP
export KAFKA_BROKER="${KAFKA_BROKER:-localhost:9092,broker:29092}"
export KSQLDB_URL="${KSQLDB_URL:-http://${CONTAINER_IP}:8088}"
export DEPLOYMENT_PLATFORM="docker"
EOF

chmod +x /etc/profile.d/00-openfactory-sdk.sh

echo "🛠️ Adding helpful aliases to /etc/bash.bashrc..."
{
  echo '# OpenFactory-SDK aliases'
  echo 'alias ksql="docker exec -it ksqldb-cli ksql http://ksqldb-server:8088"'
  echo 'alias spinup="docker compose -f /usr/local/share/openfactory-sdk/openfactory-infra/docker-compose.yml up -d; ofa setup-kafka --ksqldb-server $KSQLDB_URL"'
  echo 'alias teardown="docker compose -f /usr/local/share/openfactory-sdk/openfactory-infra/docker-compose.yml down"'
} >> /etc/bash.bashrc

echo "✅ OpenFactory SDK setup complete."
