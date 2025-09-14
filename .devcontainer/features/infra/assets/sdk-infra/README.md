# Kafka Broker Setup (Devcontainer)

This setup runs a single Kafka broker inside the devcontainer using Docker-in-Docker.  
It is configured with **two listeners** so that clients from different networks can all connect successfully.

## 🔑 Key Points

- **Listeners vs Advertised Listeners**
  - `listeners`: where the broker actually binds and accepts connections.
  - `advertised.listeners`: the addresses the broker *tells clients to use* after the initial handshake.

## ⚙️ Our Config

```yaml
KAFKA_LISTENERS: PLAINTEXT://broker:29092,CONTROLLER://broker:29093,PLAINTEXT_HOST://0.0.0.0:9092
KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://broker:29092,PLAINTEXT_HOST://${CONTAINER_IP}:9092
````

* `broker:29092` → used by services attached to the `factory-net` network.
* `${CONTAINER_IP}:9092` → used by the devcontainer itself and by any service **not** in `factory-net`.

## 📡 How Clients Connect

* **Inside the devcontainer**
  Use `${CONTAINER_IP}:9092`.

* **Service in `factory-net`**
  Use `broker:29092`.

* **Service not in `factory-net`**
  Use `${CONTAINER_IP}:9092`.

## 📝 Why Two Listeners?

Kafka always returns its `advertised.listeners` to clients after the initial bootstrap.
Having both ensures:

* Clients attached to 'factory-net' resolve `broker:29092`.
* Clients not attached to 'factory-net' can still reach the broker via the container IP.

Without both, some clients would fail once metadata is exchanged.

## 🔄 Connection Flow Diagram
```
Client starts with bootstrap address
       │
       ▼
[1] TCP connect to broker (e.g. ${CONTAINER_IP}:9092 or broker:29092)
       │
       ▼
[2] Client sends MetadataRequest
       │
       ▼
[3] Broker responds with advertised.listeners:
        - PLAINTEXT://broker:29092
        - PLAINTEXT_HOST://${CONTAINER_IP}:9092
       │
       ▼
[4] Client chooses the reachable address
       │
       ▼
[5] Client connects to correct broker for topic/partition
```
