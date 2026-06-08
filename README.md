# OpenFactory-SDK
[![version](https://img.shields.io/github/release/openfactoryio/openfactory-sdk.svg?color=blue)](https://github.com/openfactoryio/openfactory-sdk/releases)
[![OpenFactory SDK Feature](https://img.shields.io/badge/devcontainer-feature-blue?logo=visualstudiocode)](https://github.com/openfactoryio/openfactory-sdk/tree/main/.devcontainer/features)
[![License](https://img.shields.io/github/license/openfactoryio/openfactory-sdk)](LICENSE)

**OpenFactory Software Development Kit**

The **OpenFactory-SDK** provides tools to develop and test [OpenFactory](https://github.com/openfactoryio) applications in a simplified development environment. Instead of requiring a full OpenFactory and Kafka cluster setup, this SDK uses lightweight Docker containers to simulate the necessary infrastructure.

The SDK is delivered as a set of **Dev Container Features** that can be easily added to your development environment.

## 🛠 Features

Currently, the SDK provides the following Dev Container features:

| Feature ID        | Description                                                       |
| ----------------- | ----------------------------------------------------------------- |
| `infra`           | Simulates the OpenFactory infrastructure (Kafka Cluster + ksqlDB) |
| `connectors`      | Deploys OpenFactory Connectors                                    |
| `nfs-server`      | Provides a mocked NFS server for shared filesystem testing        |

Each feature can be configured independently and further combined, depending on your development needs.

## 🐳 Using OpenFactory-SDK in a Dev Container

Once installed, the features allow you to start and stop infrastructure and connector services via shell aliases.

| Feature           | Start Command              | Stop Command                 |
| ----------------- | -------------------------- | ---------------------------- |
| OpenFactory Infra | `spinup`                   | `teardown`                   |
| Connectors        | `<connector>-connector-up` | `<connector>-connector-down` |
| Mocked NFS Server | `nfs-start`                | `nfs-stop`                   |


## 🚀 Usage

For all use cases, it is recommended to use as base image `ghcr.io/openfactoryio/devcontainer-py3.XX`,
where `XX` is the Python version you wish to use (currently 12, 13 or 14).

### 1️⃣ OpenFactory Application Developers

These developers are building OpenFactory applications for a **specific OpenFactory version**. 
They should **pin the SDK feature version** to match the version running in their factory.
It is further recommended to pin the version of the base image (e.g. `ghcr.io/openfactoryio/devcontainer-py3.14:v0.5.2`) in the same way.

Example `.devcontainer/devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:3.0.1": {},
    "ghcr.io/openfactoryio/openfactory-sdk/infra:0.6.1": {},
    "ghcr.io/openfactoryio/openfactory-sdk/connectors:0.6.1": {},
    "ghcr.io/openfactoryio/openfactory-sdk/nfs-server:0.6.1": {}
  }
}
```

> 💡 **Note:** The **feature version** must match the OpenFactory version running in your factory (e.g. 0.5.5). Pinning ensures the SDK features remain compatible with the OpenFactory deployment you are targeting.

### 2️⃣ OpenFactory Core Developers

These developers contribute to OpenFactory itself. They usually want to use the **latest development version** of the SDK features and the latest OpenFactory version.

Example:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:3.0.1": {},
    "ghcr.io/openfactoryio/openfactory-sdk/infra:0.0.0-dev.05580d9": {},
    "ghcr.io/openfactoryio/openfactory-sdk/connectors:0.0.0-dev.05580d9": {}
  }
}
```

> 📝 **Note:** The latest development versions of the SDK features can be found [here](https://github.com/openfactoryio/openfactory-sdk/pkgs/container/openfactory-sdk).

---

## ⚙️ Optional Settings

Each feature provides optional configuration:

| Feature           | Option ID                   | Description                                                     | Type    | Default Value               |
| ----------------- | --------------------------- | --------------------------------------------------------------- | ------- | --------------------------- |
| `infra`           | `openfactory-version`       | Git ref (branch, tag, or commit) of OpenFactory Core to install | string  | *(matches feature version)* |
|                   | `useLocalSdk`               | Use the local SDK source code instead of installing from GitHub | boolean | `false`                     |
| `connectors`      | `shdr-gateway-version`      | Git ref of the SHDR Gateway image to install                    | string  | *(matches feature version)* |
|                   | `shdr-coordinator-version`  | Git ref of the SHDR Coordinator image to install                | string  | *(matches feature version)* |
|                   | `opcua-coordinator-version` | Git ref of the OPC UA Coordinator image to install              | string  | *(matches feature version)* |
|                   | `opcua-gateway-version`     | Git ref of the OPC UA Gateway image to install                  | string  | *(matches feature version)* |
|                   | `useLocalSdk`               | Use the local SDK source code instead of installing from GitHub | boolean | `false`                     |
| `nfs-server`      | `nfs-mountpoint`            | Path exported by the mocked NFS server                          | string  | `/ofa/nfsvolume`            |
|                   | `nfs-uid`                   | UID owning the exported NFS mountpoint                          | string  | `1200`                      |
|                   | `nfs-gid`                   | GID owning the exported NFS mountpoint                          | string  | `1200`                      |

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
  OPENFACTORY_VERSION=<value of feature option id openfactory-version>
  ```
* Add aliases:

  ```bash
  ksql      – launch the ksqlDB CLI
  spinup    – start infrastructure
  teardown  – stop infrastructure
  ```

**Connectors (`connectors`) Feature:**

* Copy OpenFactory Connector configuration files into the container
* Set environment variables:

  ```bash
  OPCUA_GATEWAY_VERSION="<version>"
  OPCUA_COORDINATOR_VERSION="<version>"
  SHDR_GATEWAY_VERSION="<version>"
  SHDR_COORDINATOR_VERSION="<version>"
  ```
* Add aliases:

  ```bash
  shdr-connector-up     # Launch the SHDR Connector
  shdr-connector-down   # Stop the SHDR Connector
  opcua-connector-up    # Launch the OPC UA Connector
  opcua-connector-down  # Stop the OPC UA Connector
  ```

**Mocked NFS Server (`nfs-server`) Feature:**

* Install helper scripts to manage a mocked NFS server
* Create a mocked NFS server container using Docker
* Create a persistent Docker volume for NFS data
* Set environment variables:

  ```bash
  NFS_CONTAINER_NAME=devcontainer-nfs
  NFS_VOLUME_NAME=devcontainer-nfsdata
  NFS_NETWORK_NAME=factory-net

  NFS_MOUNTPOINT=<value of feature option id nfs-mountpoint>
  NFS_UID=<value of feature option id nfs-uid>
  NFS_GID=<value of feature option id nfs-gid>
  ```
* Add aliases:

  ```bash
  nfs-start  – start mocked NFS server
  nfs-stop   – stop mocked NFS server
  ```

All environment variables and aliases are available in every Bash terminal inside the Dev Container.

---

## 📦 Use Cases

* [Test an OpenFactory adapter](doc/test_adapter.md)
* Develop OpenFactory applications without a full production infrastructure
* Experiment with OpenFactory Connectors in isolation or alongside the simulated infrastructure

---

## 🧪 For Feature Developers

If you're contributing to the SDK itself or developing Dev Container features, you may want to install the SDK from the local source in **editable mode**.

```json
{
  "features": {
    "ghcr.io/openfactoryio/openfactory-sdk/<feature>:latest": {
      "useLocalSdk": true
    }
  },
  "postCreateCommand": "pip install -e /workspaces/openfactory-sdk"
}
```

> ⚠️ The local SDK path (`/workspaces/openfactory-sdk`) is only available **after** the container starts — so editable installs must happen via `postCreateCommand` or `postStartCommand`, not inside the feature itself.
