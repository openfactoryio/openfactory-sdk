#!/bin/bash
# -----------------------------------------------------------------------------
# Dev Kafka Topic Creation Script using YAML
# -----------------------------------------------------------------------------
# Reads topics.yml and creates each topic via docker exec broker kafka-topics
# Needs: yq installed (sudo apt install yq)
# -----------------------------------------------------------------------------

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOPIC_FILE="$SCRIPT_DIR/topics.yml"
BOOTSTRAP_SERVER="broker:29092"

echo "Creating Kafka topics from $TOPIC_FILE ..."

# Temporary array to hold summary info
declare -a SUMMARY

# Number of topics
NUM_TOPICS=$(yq '.topics | length' "$TOPIC_FILE")

# Loop over each topic
for i in $(seq 0 $((NUM_TOPICS - 1))); do
    NAME=$(yq -r ".topics[$i].name" "$TOPIC_FILE")
    PARTITIONS=$(yq -r ".topics[$i].partitions" "$TOPIC_FILE")
    REPLICATION=$(yq -r ".topics[$i].replication" "$TOPIC_FILE")
    CLEANUP=$(yq -r ".topics[$i].cleanup" "$TOPIC_FILE")
    COMMENT=$(yq -r ".topics[$i].comment" "$TOPIC_FILE")

    echo "Processing topic: $NAME ($COMMENT)"

    # Attempt to create topic (silently, --if-not-exists)
    docker exec broker kafka-topics --bootstrap-server $BOOTSTRAP_SERVER --create \
      --topic "$NAME" \
      --partitions "$PARTITIONS" \
      --replication-factor "$REPLICATION" \
      --config cleanup.policy="$CLEANUP" \
      --if-not-exists >/dev/null 2>&1

    # Get actual topic info from Kafka
    INFO=$(docker exec broker kafka-topics --bootstrap-server $BOOTSTRAP_SERVER --describe --topic "$NAME" 2>/dev/null)

    # Extract actual partitions and replication factor
    ACTUAL_PARTS=$(echo "$INFO" | grep -oP 'PartitionCount:[[:space:]]*\K[0-9]+')
    ACTUAL_REPL=$(echo "$INFO" | grep -oP 'ReplicationFactor:[[:space:]]*\K[0-9]+')

    # Determine status
    if [[ -z "$INFO" ]]; then
        STATUS="failed"
        ACTUAL_PARTS="?"
        ACTUAL_REPL="?"
    else
        # If the topic existed before, we consider it "exists", otherwise "created"
        # Simplest way: always mark as exists if info is returned (since --if-not-exists)
        STATUS="exists/created"
    fi

    # Save info for summary
    SUMMARY+=("$NAME|$ACTUAL_PARTS|$ACTUAL_REPL|$CLEANUP|$STATUS")
done


# Print summary table
echo
echo "----------------------------------------------------------------------------------------------------"
printf "%-30s %-10s %-12s %-10s %-15s\n" "Topic" "Partitions" "Replication" "Cleanup" "Status"
echo "----------------------------------------------------------------------------------------------------"
for row in "${SUMMARY[@]}"; do
    IFS='|' read -r name parts repl cleanup status <<< "$row"
    printf "%-30s %-10s %-12s %-10s %-15s\n" "$name" "$parts" "$repl" "$cleanup" "$status"
done
echo "----------------------------------------------------------------------------------------------------"
echo "All topics processed."
