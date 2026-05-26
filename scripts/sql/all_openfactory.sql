SET 'auto.offset.reset' = 'earliest';

-- ---------------------------------------------------------------------
-- Main topology

-- OpenFactory Assets data stream
CREATE STREAM IF NOT EXISTS assets_stream (
        asset_uuid VARCHAR KEY,
        id VARCHAR,
        value VARCHAR,
        tag VARCHAR,
        type VARCHAR,
        attributes MAP<VARCHAR, VARCHAR>
    ) WITH (
        KAFKA_TOPIC = 'ofa_assets',
        VALUE_FORMAT = 'JSON'
    );

-- OpenFactory Assets data stream with composite key
CREATE STREAM IF NOT EXISTS enriched_assets_stream (
    key VARCHAR KEY,
    asset_uuid VARCHAR,
    id VARCHAR,
    value VARCHAR,
    type VARCHAR,
    tag VARCHAR,
    timestamp VARCHAR
) WITH (
    KAFKA_TOPIC = 'enriched_assets_stream_topic',
    VALUE_FORMAT = 'JSON'
) AS SELECT 
    concat(CAST(asset_uuid AS STRING), '|', CAST(id AS STRING)) AS key,
    asset_uuid,
    id,
    value,
    type,
    tag,
    COALESCE(attributes['timestamp'], 'UNAVAILABLE') AS timestamp
FROM assets_stream
PARTITION BY concat(CAST(asset_uuid AS STRING), '|', CAST(id AS STRING));

-- OpenFactory Assets data table
CREATE TABLE IF NOT EXISTS assets AS
  SELECT 
    key,
    LATEST_BY_OFFSET(asset_uuid) AS asset_uuid,
    LATEST_BY_OFFSET(id) AS id,
    LATEST_BY_OFFSET(value) AS value,
    LATEST_BY_OFFSET(type) AS type,
    LATEST_BY_OFFSET(tag) AS tag,
    LATEST_BY_OFFSET(timestamp) AS timestamp
  FROM enriched_assets_stream
  GROUP BY key;

  -- OpenFactory Assets data table aggregated by ASSET_UUID
  CREATE TABLE IF NOT EXISTS assets_aggregated_by_asset_uuid AS
  SELECT 
    asset_uuid,
    COLLECT_LIST(
      STRUCT(
        id := id,
        value := value,
        type := type,
        tag := tag,
        timestamp := timestamp
      )
    ) AS readings
  FROM assets
  GROUP BY asset_uuid;


-- ---------------------------------------------------------------------
-- Docker Swarm services of assets

-- Stream for Docker services of OpenFactory Assets
CREATE STREAM IF NOT EXISTS docker_services_stream WITH (
    KAFKA_TOPIC = 'docker_services_topic',
    VALUE_FORMAT = 'JSON'
) AS 
SELECT asset_uuid, VALUE AS docker_service
FROM assets_stream 
WHERE ID = 'DockerService' AND TYPE = 'OpenFactory';

-- Table for Docker services of OpenFactory Assets
CREATE SOURCE TABLE IF NOT EXISTS docker_services (
    asset_uuid VARCHAR PRIMARY KEY,
    docker_service VARCHAR
) WITH (
    KAFKA_TOPIC = 'docker_services_topic',
    VALUE_FORMAT = 'JSON'
);

-- ---------------------------------------------------------------------
-- Assets deployed on OpenFactory cluster 

-- Stream for OpenFactory Assets tombstones
CREATE STREAM IF NOT EXISTS assets_type_tombstones WITH (
    KAFKA_TOPIC = 'assets_types_topic',
    VALUE_FORMAT = 'KAFKA'
) AS 
SELECT asset_uuid, CAST(NULL AS VARCHAR) AS type
FROM assets_stream
WHERE ID = 'AssetType' AND TYPE = 'OpenFactory' AND VALUE = 'delete';

-- Stream for OpenFactory Assets types
CREATE STREAM IF NOT EXISTS assets_type_stream WITH (
    KAFKA_TOPIC = 'assets_types_topic',
    VALUE_FORMAT = 'JSON'
) AS 
SELECT asset_uuid, value AS type
FROM assets_stream 
WHERE ID = 'AssetType' AND TYPE = 'OpenFactory';

-- Table for OpenFactory Assets
CREATE SOURCE TABLE IF NOT EXISTS assets_type (
    asset_uuid VARCHAR PRIMARY KEY,
    type VARCHAR
) WITH (
    KAFKA_TOPIC = 'assets_types_topic',
    VALUE_FORMAT = 'JSON'
);

-- ---------------------------------------------------------------------
-- OpenFactory Assets availability

-- Stream for assets availability tombstones
CREATE STREAM IF NOT EXISTS assets_avail_tombstones WITH (
    KAFKA_TOPIC = 'assets_avail_topic',
    VALUE_FORMAT = 'KAFKA'
) AS 
SELECT asset_uuid, CAST(NULL AS VARCHAR) AS value
FROM assets_stream
WHERE (id IN ('avail', 'agent_avail') AND value = 'delete');

-- Stream for assets availability
CREATE STREAM IF NOT EXISTS assets_avail_stream WITH (
    KAFKA_TOPIC = 'assets_avail_topic',
    VALUE_FORMAT = 'JSON'
) AS 
SELECT asset_uuid, value AS availability
FROM assets_stream 
WHERE (id IN ('avail', 'agent_avail') AND value != 'delete');

-- Table for assets availability status
CREATE SOURCE TABLE IF NOT EXISTS assets_avail (
    asset_uuid VARCHAR PRIMARY KEY,
    availability VARCHAR
) WITH (
    KAFKA_TOPIC = 'assets_avail_topic',
    VALUE_FORMAT = 'JSON'
);

-- ---------------------------------------------------------------------
-- Mapping between ASSET_UUID and UNS_ID

-- Source table for mapping between asset_uuid and uns_id
CREATE TABLE IF NOT EXISTS asset_to_uns_map_raw (
    asset_uuid VARCHAR PRIMARY KEY,
    uns_id VARCHAR,
    uns_levels MAP<VARCHAR, VARCHAR>,
    updated_at TIMESTAMP
) WITH (
    KAFKA_TOPIC = 'asset_to_uns_map_topic',
    KEY_FORMAT = 'KAFKA',
    VALUE_FORMAT = 'JSON'
);

-- Materialized table for querying and joining
CREATE TABLE IF NOT EXISTS asset_to_uns_map AS
SELECT * FROM asset_to_uns_map_raw EMIT CHANGES;


-- ---------------------------------------------------------------------
-- OpenFactory Assets data stream keyed by uns_id

-- Create assets_stream_uns
CREATE STREAM IF NOT EXISTS assets_stream_uns (
    uns_id VARCHAR KEY,
    asset_uuid VARCHAR,
    id VARCHAR,
    value VARCHAR,
    tag VARCHAR,
    type VARCHAR,
    attributes MAP<VARCHAR, VARCHAR>
) WITH (
    KAFKA_TOPIC = 'ofa_assets_uns',
    VALUE_FORMAT = 'JSON'
) AS SELECT
    m.uns_id AS uns_id,
    a.asset_uuid AS asset_uuid,
    a.id,
    a.value,
    a.tag,
    a.type,
    a.attributes
FROM assets_stream a
LEFT JOIN asset_to_uns_map m
    ON a.asset_uuid = m.asset_uuid
WHERE m.uns_id IS NOT NULL
PARTITION BY m.uns_id;


-- ---------------------------------------------------------------------
-- OpenFactory assets data table keyed by uns_id

CREATE TABLE IF NOT EXISTS assets_uns AS
SELECT
  concat(m.uns_id, '|', a.id) AS key,  -- new composite key with uns_id (will become table key)
  a.key AS asset_uuid_key,
  m.uns_id AS uns_id,
  a.asset_uuid AS asset_uuid,
  a.id AS id,
  a.value AS value,
  a.type AS type,
  a.tag AS tag,
  a.timestamp AS timestamp
FROM assets a
LEFT JOIN asset_to_uns_map m
  ON a.asset_uuid = m.asset_uuid
WHERE m.uns_id IS NOT NULL;

-- ---------------------------------------------------------------------
-- Connector configuration for devices

-- Base definition (backed by Kafka topic, not directly queryable)
CREATE TABLE IF NOT EXISTS DEVICE_CONNECTOR_SOURCE (
    ASSET_UUID STRING PRIMARY KEY,
    CONNECTOR_CONFIG STRING
) WITH (
    KAFKA_TOPIC='device_connector_topic',
    VALUE_FORMAT='JSON'
);

-- Materialized version (queryable)
CREATE TABLE IF NOT EXISTS DEVICE_CONNECTOR AS
    SELECT ASSET_UUID, CONNECTOR_CONFIG
    FROM DEVICE_CONNECTOR_SOURCE
    EMIT CHANGES;