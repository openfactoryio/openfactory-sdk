#!/bin/bash
set -e
#
# spinup.sh - Start the OpenFactory stack inside the devcontainer
#
# This script will:
#   1. Start the Kafka cluster defined in docker-compose.yml
#   2. Setup required Kafka topics
#   3. Initialize the OpenFactory stream processing topology via ofa setup-kafka
#   4. Start the fan-out layer defined in docker-compose.fan-out-layer.yml
#
# Environment variables:
#   KSQLDB_URL - URL of the ksqlDB server (defaults set in install.sh profile script)
#
# Usage:
#   spinup.sh
#

echo "🚀  Starting OpenFactory stack..."

# Location of docker-compose file
SDK_PATH="/usr/local/share/openfactory-sdk"
KAFKA_COMPOSE_FILE="${SDK_PATH}/openfactory-infra/docker-compose.yml"
FAN_OUT_LAYER_COMPOSE_FILE="${SDK_PATH}/openfactory-fanoutlayer/docker-compose.yml"

# Spin up containers
echo "🐳  Deploying Kafka CLuster ..."
docker compose -f "$KAFKA_COMPOSE_FILE" -p kafka-cluster up -d

# Setup required Kafka topics
echo "⚙️  Setting up Kafka topics ..."
/usr/local/bin/create_topics.sh

# Run OpenFactory setup
echo "⚙️  Deploying OpenFactory stream processing topology ..."
ofa setup-kafka --ksqldb-server "${KSQLDB_URL}"

# Setup OpenFactory Fan-out Layer
echo "🐳  Deploying OpenFactory fan-out layer ..."
docker compose -f "$FAN_OUT_LAYER_COMPOSE_FILE" -p fan-out-layer up -d --scale asset-forwarder=1 --scale asset-router=1

echo "✅  OpenFactory stack is ready!"
