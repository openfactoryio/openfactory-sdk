# OpenFactory-SDK
[![OpenFactory SDK Feature](https://img.shields.io/badge/devcontainer-feature-blue?logo=visualstudiocode)](https://github.com/openfactoryio/openfactory-sdk/tree/main/.devcontainer/features)

**OpenFactory Software Development Kit**

The **OpenFactory-SDK** provides tools to develop and test [OpenFactory](https://github.com/openfactoryio) applications in a simplified development environment. Instead of requiring a full OpenFactory and Kafka cluster setup, this SDK uses lightweight Docker containers to simulate the necessary infrastructure.

---

## 🐳 Deploy OpenFactory-SDK in a Dev Container

The SDK includes a Dev Container **Feature** that automatically sets up the OpenFactory infrastructure inside your development environment.

### ✨ Usage

Add the following to your `.devcontainer/devcontainer.json`:

```json
{
  "features": {
    "docker-in-docker": {
      "version": "latest"
    },
    "ghcr.io/openfactoryio/openfactory-sdk/infra:latest"
  }
}
```
This setup works out of the box with sensible defaults and requires no configuration in most cases.

For advanced use cases, the feature also exposes the following optional settings:

| Option ID             | Description                                                     | Type    | Default Value               |
| --------------------- | --------------------------------------------------------------- | ------- | --------------------------- |
| `openfactory-version` | Git ref (branch, tag, or commit) of OpenFactory Core to install | string  | *(matches feature version)* |
| `useLocalSdk`         | Use the local SDK source code instead of installing from GitHub | boolean | `false`                     |

> 📝 **Note:** The default `openfactory-version` is automatically set to the OpenFactory Core version that this SDK feature was developed and tested against. You typically don’t need to override it unless you're testing against a different core version.

### ✅ What This Feature Does

* Install OpenFactory with the desired version

* Install the OpenFactory SDK

* Copy the OpenFactory infrastructure files into your dev container (under `/usr/local/share/openfactory-sdk/openfactory-infra`)
* Define these environment variables:
  ```
  CONTAINER_IP=<DEV_CONTAINER-IP>
  KAFKA_BROKER=localhost:9092,broker:29092
  KSQLDB_URL=http://$CONTAINER_IP:8088
  ```

* Add these shell aliases:
  ```
  ksql      – launch the ksqlDB CLI
  spinup    – start infrastructure with Docker Compose
  teardown  – tear down the infrastructure
  ```

  The environment variables and aliases are available in every Bash terminal inside your dev container.

* Configure the environment to deploy to the OpenFactory infrastructure inside the development container

  To deploy OpenFactory assets such as devices or applications on the development infrastructure, use the `ofa` command-line tool provided by OpenFactory.

  You can get help and explore available commands by running:
  ```bash
  ofa --help
  ```

## 📦 Use cases

* [Test an OpenFactory adapter](doc/test_adapter.md)

## 🧪 For Feature Developers

If you're contributing to the SDK itself or developing the Dev Container feature, you may want to install the SDK from the local source in editable mode.

Set this in `.devcontainer/devcontainer.json`:

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
