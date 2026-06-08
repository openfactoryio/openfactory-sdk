# OpenFactory Connector Dev Container Feature

Installs **OpenFactory Connectors** inside your Dev Container.

## 🐳 Deploy OpenFactory Connectors

Once installed, the feature allows you to deploy OpenFactory Connectors.

Currently two connectors are available:
 - SHDR Connector
 - OPC UA Connector

Start the OPC UA Connector services (example):
```bash
opcua-connector-up
```

Stop the OPC UA Connector services (example):
```bash
opcua-connector-down
```

## 🚀 Usage

This section describes how to configure the feature in your devcontainer depending on your use case.

> ⚠️ **Prerequisite:** An OpenFactory infrastructure (Kafka Cluster and ksqlDB) must be set up first. Use the **Infrastructure Feature** of the SDK to achieve this.

### 1️⃣ OpenFactory Application Developers

Application developers building OpenFactory applications should **pin the SDK feature version** to match the OpenFactory version running in their factory.

Example configuration:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:3.0.1": {},
    "ghcr.io/openfactoryio/openfactory-sdk/infra:0.6.1": {},
    "ghcr.io/openfactoryio/openfactory-sdk/connectors:0.6.1": {}
  }
}
```

> 💡 **Tip:** Version pinning ensures compatibility with the OpenFactory Core version running in your factory.

### 2️⃣ OpenFactory Core Developers

Core developers contributing to OpenFactory usually want the **latest development version** of the SDK and Connectors features.

Example configuration:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:3.0.1": {},
    "ghcr.io/openfactoryio/openfactory-sdk/connectors:0.0.0-dev.05580d9": {}
  }
}
```

> 📝 **Note:** The latest development version of the SDK feature can be found [here](https://github.com/openfactoryio/openfactory-sdk/pkgs/container/openfactory-sdk%2Fconnectors).

---

## ⚙️ Optional Settings

| Option ID                   | Description                                                 | Type    | Default Value               |
| --------------------------- | ----------------------------------------------------------- | ------- | --------------------------- |
| `shdr-coordinator-version`  | Git ref of the SHDR Coordinator image to install            | string  | *(matches feature version)* |
| `shdr-gateway-version`      | Git ref of the SHDR Gateway image to install                | string  | *(matches feature version)* |
| `opcua-coordinator-version` | Git ref of the OPC UA Coordinator image to install          | string  | *(matches feature version)* |
| `opcua-gateway-version`     | Git ref of the OPC UA Gateway image to install              | string  | *(matches feature version)* |
| `useLocalSdk`               | Use local SDK source code instead of installing from GitHub | boolean | `false`                     |

> 📝 **Note:** The default `<connector>-coordinator-version` and `<connector>-gateway-version` match the OpenFactory Core version this feature was developed and tested against. Most users do not need to override it.

---

## ✅ What This Feature Does

* Copies the OpenFactory Connector configuration files to `/usr/local/share/openfactory-connectors`.

* Defines the following environment variables:
  ```bash
  OPCUA_GATEWAY_VERSION="<version>"
  OPCUA_COORDINATOR_VERSION="<version>"
  SHDR_GATEWAY_VERSION="<version>"
  SHDR_COORDINATOR_VERSION="<version>"
  ```
  where `<version>` is set from the corresponding feature options in your `devcontainer.json`.

* Adds these shell aliases:
  ```bash
  shdr-connector-up     # Launch the SHDR Connector
  shdr-connector-down   # Stop the SHDR Connector
  opcua-connector-up    # Launch the OPC UA Connector
  opcua-connector-down  # Stop the OPC UA Connector
  ```

## 📝 Connector Logging

The connector deployment files support configuring the log level of coordinators and gateways through environment variables.

### SHDR Connector

```bash
export SHDR_COORDINATOR_LOG_LEVEL=DEBUG
export SHDR_GATEWAY_LOG_LEVEL=DEBUG
shdr-connector-up
```

### OPC UA Connector

```bash
export OPCUA_COORDINATOR_LOG_LEVEL=DEBUG
export OPCUA_GATEWAY_LOG_LEVEL=DEBUG
opcua-connector-up
```

Supported log levels depend on the connector implementation. By default, all components use `INFO`.


## 🧪 For Feature Developers

If you're contributing to this feature, you may want to install it from the local source in editable mode.

Example `.devcontainer/devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/openfactoryio/openfactory-sdk/connectors:latest": {
      "useLocalSdk": true
    }
  },
  "postCreateCommand": "pip install -e /workspaces/openfactory-sdk"
}
```
