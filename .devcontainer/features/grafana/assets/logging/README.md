# Grafana Loki Configuration

The OpenFactory logging stack uses Grafana Loki to store and query container logs.

Grafana must be configured with Loki as a data source before collected logs can be explored and visualized.

## Add Loki as a Grafana Data Source

In Grafana:

1. Open **Connections → Data sources**.
2. Select **Add new data source**.
3. Select **Loki**.
4. Configure the Loki server URL as:

```
http://loki:3100
```

5. Leave authentication disabled.
6. Select **Save & test**.

Grafana and Loki are connected to the shared `factory-net` Docker network, allowing Grafana to access Loki directly using the Docker service name `loki`.

Loki does not need to expose port `3100` on the Docker hosts.

## Explore Logs

Open **Explore** in Grafana and select the Loki data source.

Logs can be queried using the labels added by the Grafana Alloy collection pipeline.

For example, to display logs from a specific container:

```logql
{container="opcua-gateway-1"}
```

Available labels include:

* `container` — Docker container name
* `service` — Docker Swarm service name
* `node_id` — Docker Swarm node identifier

Container logs may contain either plain text or structured JSON.

OpenFactory Apps configured with the Loki logging backend emit structured JSON logs, allowing fields such as the log level, logger name, message, and application-defined logging context to be inspected and queried in Grafana.
