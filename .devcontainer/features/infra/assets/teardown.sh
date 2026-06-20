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
TRAEFIK_COMPOSE_FILE="${SDK_PATH}/openfactory-infra/docker-compose.traefik.yml"
FAN_OUT_LAYER_COMPOSE_FILE="${SDK_PATH}/openfactory-infra/docker-compose.nats.yml"
PROMETHEUS_COMPOSE_FILE="${SDK_PATH}/openfactory-infra/docker-compose.prometheus.yml"

# Tear down OpenFactory Apps
echo "🏭 Removing OpenFactory Apps"
ofa apps down ${SDK_PATH}/openfactory-infra/monitoring/
ofa apps down ${SDK_PATH}/openfactory-infra/fanoutlayer

# Tear down fan-out layer
echo "🐳  Stopping OpenFactory fan-out layer..."
docker compose -f "$FAN_OUT_LAYER_COMPOSE_FILE" -p fan-out-layer down -v

# Tear down Traefik
echo "🐳  Stopping Traefik..."
docker compose -f "$TRAEFIK_COMPOSE_FILE" -p traefik down -v

# Tear down Prometheus
echo "🐳  Stopping Prometheus..."
docker compose -f "$PROMETHEUS_COMPOSE_FILE" -p prometheus down -v

# Tear down Kafka cluster
echo "🐳  Stopping Kafka cluster..."
docker compose -f "$KAFKA_COMPOSE_FILE" -p kafka-cluster down -v

echo "✅  OpenFactory stack stopped!"
