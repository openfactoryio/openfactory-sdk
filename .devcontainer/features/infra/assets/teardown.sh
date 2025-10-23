#!/bin/bash
set -e
#
# teardown.sh - Stop the OpenFactory stack inside the devcontainer
#
# This script will:
#   1. Stop the fan-out layer defined in docker-compose.fan-out-layer.yml
#   2. Stop the Kafka cluster defined in docker-compose.yml
#
# Usage:
#   teardown.sh
#

echo "🛑  Stopping OpenFactory stack..."

# Common path for infra files
SDK_PATH="/usr/local/share/openfactory-sdk"

# Compose files
KAFKA_COMPOSE_FILE="${SDK_PATH}/openfactory-infra/docker-compose.yml"
FAN_OUT_LAYER_COMPOSE_FILE="${SDK_PATH}/openfactory-fanoutlayer/docker-compose.yml"

# Tear down fan-out layer first
echo "🐳  Stopping OpenFactory fan-out layer..."
docker compose -f "$FAN_OUT_LAYER_COMPOSE_FILE" -p fan-out-layer down -v

# Tear down Kafka cluster
echo "🐳  Stopping Kafka cluster..."
docker compose -f "$KAFKA_COMPOSE_FILE" -p kafka-cluster down -v

echo "✅  OpenFactory stack stopped!"
