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

echo "📁 Copying Connectors files..."
mkdir -p "/usr/local/share/openfactory-grafana"
cp -r "$(dirname "$0")/assets/." "/usr/local/share/openfactory-grafana"

# Set aliases
echo "🛠️ Adding helpful aliases to /etc/bash.bashrc..."
{
  echo "alias grafana-up='docker compose -f /usr/local/share/openfactory-grafana/grafana/docker-compose.yml -p grafana up -d'"
  echo "alias grafana-down='docker compose -f /usr/local/share/openfactory-grafana/grafana/docker-compose.yml -p grafana down'"
  echo "alias logging-up='docker compose -f /usr/local/share/openfactory-grafana/logging/docker-compose.yml -p logging up -d'"
  echo "alias logging-down='docker compose -f /usr/local/share/openfactory-grafana/logging/docker-compose.yml -p logging down'"
} >> /etc/bash.bashrc

echo "✅ OpenFactory Grafana feature setup complete."