# OpenFactory-SDK
[![OpenFactory SDK Feature](https://img.shields.io/badge/devcontainer-feature-blue?logo=visualstudiocode)](https://github.com/openfactoryio/openfactory-sdk/tree/main/.devcontainer/features)

**OpenFactory Software Development Kit**

The **OpenFactory-SDK** provides tools to develop and test [OpenFactory](https://github.com/openfactoryio) applications in a simplified development environment. Instead of requiring a full OpenFactory and Kafka cluster setup, this SDK uses lightweight Docker containers to simulate the necessary infrastructure.

The SDK is delivered as a set of **Dev Container Features** that can be easily added to your development environment.

## 🛠 Features

Currently, the SDK provides the following Dev Container features:

| Feature ID        | Description                                                       |
| ----------------- | ----------------------------------------------------------------- |
| `infra`           | Simulates the OpenFactory infrastructure (Kafka Cluster + ksqlDB) |
| `opcua-connector` | Deploys an OpenFactory OPC UA Connector for application testing   |

Each feature can be configured independently and further combined, depending on your development needs.

## 🐳 Using OpenFactory-SDK in a Dev Container

Once installed, the features allow you to start and stop infrastructure and OPC UA Connector services via shell aliases.

| Feature           | Start Command        | Stop Command           |
| ----------------- | -------------------- | ---------------------- |
| OpenFactory Infra | `spinup`             | `teardown`             |
| OPC UA Connector  | `opcua-connector-up` | `opcua-connector-down` |


## 🚀 Usage

### 1️⃣ OpenFactory Application Developers

These developers are building OpenFactory applications for a **specific OpenFactory version**. They should **pin the SDK feature version** to match the version running in their factory.

Example `.devcontainer/devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/openfactoryio/openfactory-sdk/infra:0.4.2": {},
    "ghcr.io/openfactoryio/openfactory-sdk/opcua-connector:0.4.2": {}
  }
}
```

> 💡 **Note:** Version pinning ensures that the SDK features match the OpenFactory version you are targeting.

### 2️⃣ OpenFactory Core Developers

These developers contribute to OpenFactory itself. They usually want to use the **latest development version** of the SDK features and the latest OpenFactory version.

Example:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/openfactoryio/openfactory-sdk/infra:0.0.0-dev.05580d9": {
      "openfactory-version": "main"
    },
    "ghcr.io/openfactoryio/openfactory-sdk/opcua-connector:0.0.0-dev.05580d9": {
      "opcua-connector-version": "latest"
    }
  }
}
```

> 📝 **Note:** The latest development version of the SDK features can be found [here](https://github.com/openfactoryio/openfactory-sdk/pkgs/container/openfactory-sdk).

---

## ⚙️ Optional Settings

Each feature provides optional configuration:

| Feature           | Option ID                 | Description                                                     | Type    | Default Value               |
| ----------------- | ------------------------- | --------------------------------------------------------------- | ------- | --------------------------- |
| `infra`           | `openfactory-version`     | Git ref (branch, tag, or commit) of OpenFactory Core to install | string  | *(matches feature version)* |
|                   | `useLocalSdk`             | Use the local SDK source code instead of installing from GitHub | boolean | `false`                     |
| `opcua-connector` | `opcua-connector-version` | Git ref of the OPC UA Connector image to install                | string  | *(matches feature version)* |
|                   | `useLocalSdk`             | Use the local SDK source code instead of installing from GitHub | boolean | `false`                     |

---

## ✅ What the SDK Features Do

**Infrastructure (`infra`) Feature:**

* Install OpenFactory Core and SDK (matching the feature version)
* Deploy Kafka cluster and ksqlDB using Docker Compose
* Set environment variables:

  ```bash
  CONTAINER_IP=<DEV_CONTAINER-IP>
  KAFKA_BROKER=$CONTAINER_IP:9092,broker:29092
  KSQLDB_URL=http://$CONTAINER_IP:8088
  ```
* Add aliases:

  ```bash
  ksql      – launch the ksqlDB CLI
  spinup    – start infrastructure
  teardown  – stop infrastructure
  ```

**OPC UA Connector (`opcua-connector`) Feature:**

* Copy OPC UA Connector Docker files into the container
* Define environment variable:

  ```bash
  OPCUA_CONNECTOR_VERSION="<version>"
  ```
* Add aliases:

  ```bash
  opcua-connector-up    – launch OPC UA Connector
  opcua-connector-down  – stop OPC UA Connector
  ```

All environment variables and aliases are available in every Bash terminal inside the Dev Container.

---

## 📦 Use Cases

* [Test an OpenFactory adapter](doc/test_adapter.md)
* Develop OpenFactory applications without a full production infrastructure
* Experiment with the OPC UA Connector in isolation or alongside the simulated infrastructure

---

## 🧪 For Feature Developers

If you're contributing to the SDK itself or developing Dev Container features, you may want to install the SDK from the local source in **editable mode**.

```json
{
  "features": {
    "ghcr.io/openfactoryio/openfactory-sdk/infra:latest": {
      "useLocalSdk": true
    }
  },
  "postCreateCommand": "pip install -e /workspaces/openfactory-sdk"
}
```

> ⚠️ The local SDK path (`/workspaces/openfactory-sdk`) is only available **after** the container starts — so editable installs must happen via `postCreateCommand` or `postStartCommand`, not inside the feature itself.
