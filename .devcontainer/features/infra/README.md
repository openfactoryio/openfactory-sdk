# OpenFactory Infrastructure Feature

Installs a simulated OpenFactory infrastructure (Kafka Cluster and ksqlDB) in a Dev Container.

## 🐳 Deploy OpenFactory Infrastructure in a Dev Container

Once installed, the feature automatically sets up a simulated OpenFactory infrastructure inside your development environment
including Treafik routing (with base domain `openfactory.local`).

The simulated infrastructure can be deployed with:
```bash
spinup
```
and torn down with:
```bash
teardown
```

## 🚀 Usage

This section describes how to configure the feature in your devcontainer depending on your use case.

### 1️⃣ OpenFactory Application Developers

These developers are building OpenFactory applications for a specific OpenFactory version. 
They should **pin the SDK feature version** to match the OpenFactory version running in their factory.

Example:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/openfactoryio/openfactory-sdk/infra:0.4.2": {}
  }
}
```

> 💡 **Note:** Version pinning ensures the feature is the one for their specific OpenFactory version.

### 2️⃣ OpenFactory Core Developers

These developers contribute to OpenFactory itself.
They usually want to use the **latest development version** of the SDK feature, and the latest OpenFactory version, which is `main`.

Example:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/openfactoryio/openfactory-sdk/infra:0.0.0-dev.05580d9": {
      "openfactory-version": "main"
    }
  }
}
```

> 📝 **Note:** The latest development version of the SDK feature can be found [here](https://github.com/openfactoryio/openfactory-sdk/pkgs/container/openfactory-sdk%2Finfra).


### ⚙️ Optional Settings

For advanced use cases, the feature also exposes the following optional settings:

| Option ID             | Description                                                     | Type    | Default Value               |
| --------------------- | --------------------------------------------------------------- | ------- | --------------------------- |
| `openfactory-version` | Git ref (e.g. v1.2.3 or main) of OpenFactory Core to install    | string  | *(matches feature version)* |
| `useLocalSdk`         | Use the local SDK source code instead of installing from GitHub | boolean | `false`                     |

> 📝 **Note:** The default `openfactory-version` is automatically set to the OpenFactory Core version that this SDK feature was developed and tested against. Most users do not need to override it.

## ✅ What This Feature Does

* Install OpenFactory with the desired version (matching the feature version)

* Install the OpenFactory SDK

* Copy the OpenFactory infrastructure files into your dev container (under `/usr/local/share/openfactory-sdk/openfactory-infra`)

* Defines the following environment variables:
  ```
  CONTAINER_IP=<DEV_CONTAINER-IP>
  KAFKA_BROKER=$CONTAINER_IP:9092,broker:29092
  KSQLDB_URL=http://$CONTAINER_IP:8088
  ```
  where `<DEV_CONTAINER-IP>` is automatically determined for your Dev Container.

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

## 🌐 Access Applications API (Traefik Routing)

OpenFactory applications deployed inside the dev container are exposed via **Traefik**, allowing you to access them from your browser.

There are two ways to access applications:

### 1️⃣ Inside the Dev Container (recommended for development)

Applications are available via DNS-based hostnames:
```bash
http://<app-uuid>.openfactory.local
```

Example:
```bash
curl http://demo-fastapi-app.openfactory.local/docs
```

This works because the feature configures internal DNS using `dnsmasq`.

### 2️⃣ From your Host Machine (browser access)

To access applications from your host machine, OpenFactory provides **path-based routing via localhost**.

#### Step 1: Forward port 80 in your devcontainer

Add to your `.devcontainer/devcontainer.json`:
```json
{
  "forwardPorts": [80],
  "portsAttributes": {
    "80": {
      "label": "Traefik",
      "onAutoForward": "openBrowser"
    }
  }
}
```

#### Step 2: Access applications via localhost

Applications are available at:
```bash
http://localhost/<app-uuid>
```

Example:
```bash
http://localhost/demo-fastapi-app/docs
```
The Traefik dahsboard itself is accesible via
```bash
http://loalhost/dashboard/
```

## ⚙️ How it works

* Traefik routes requests using:

  * **Host-based routing** inside the container
    ```
    <app-uuid>.openfactory.local
    ```
  * **Path-based routing** from the host
    ```
    localhost/<app-uuid>
    ```

* When using path-based routing, OpenFactory automatically sets:

  ```bash
  OPENFACTORY_ROOT_PATH=/<app-name>
  ```
  This allows applications to correctly generate URLs (e.g. Swagger, redirects).

> 💡 Tip: You can verify DNS inside the container with:
> `getent hosts <app-name>.openfactory.local`

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
