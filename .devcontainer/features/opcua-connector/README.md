# OpenFactory OPC UA Connector Dev Container Feature

Installs the **OpenFactory OPC UA Connector** inside your Dev Container.

## 🐳 Deploy OpenFactory OPC UA Connector

Once installed, the feature allows you to deploy an OpenFactory OPC UA Connector.

Start the OPC UA Connector services:
```bash
opcua-connector-up
```

Stop the OPC UA Connector services:
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
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/openfactoryio/openfactory-sdk/infra:0.4.2": {},
    "ghcr.io/openfactoryio/openfactory-sdk/opcua-connector:0.4.2": {}
  }
}
```

> 💡 **Tip:** Version pinning ensures compatibility with the OpenFactory Core version running in your factory.

### 2️⃣ OpenFactory Core Developers

Core developers contributing to OpenFactory usually want the **latest development version** of the SDK feature and OPC UA Connector.

Example configuration:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/openfactoryio/openfactory-sdk/opcua-connector:0.0.0-dev.05580d9": {
      "opcua-connector-version": "latest"
    }
  }
}
```

> 📝 **Note:** The latest development version of the SDK feature can be found [here](https://github.com/openfactoryio/openfactory-sdk/pkgs/container/openfactory-sdk%2Finfra).

---

## ⚙️ Optional Settings

| Option ID                 | Description                                                 | Type    | Default Value               |
| ------------------------- | ----------------------------------------------------------- | ------- | --------------------------- |
| `opcua-connector-version` | Git ref of the OPC UA Connector image to install            | string  | *(matches feature version)* |
| `useLocalSdk`             | Use local SDK source code instead of installing from GitHub | boolean | `false`                     |

> 📝 **Note:** The default `opcua-connector-version` matches the OpenFactory Core version this feature was developed and tested against. Most users do not need to override it.

---

## ✅ What This Feature Does

* Copies the `docker-compose.yml` needed for the OPC UA Connector to `/usr/local/share/openfactory-opcua`.

* Defines the following environment variable:
  ```bash
  OPCUA_CONNECTOR_VERSION="<version>"
  ```
  where `<version>` is the `opcua-connector-version` set in the feature definition of your `devcontainer.json`.


* Adds these shell aliases:
  ```bash
  opcua-connector-up    # Launch the OPC UA Connector infrastructure
  opcua-connector-down  # Stop the OPC UA Connector infrastructure
  ```

## 🧪 For Feature Developers

If you're contributing to this feature, you may want to install it from the local source in editable mode.

Example `.devcontainer/devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/openfactoryio/openfactory-sdk/opcua-connector:latest": {
      "useLocalSdk": true
    }
  },
  "postCreateCommand": "pip install -e /workspaces/openfactory-sdk"
}
```
