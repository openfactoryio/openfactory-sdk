# OpenFactory-SDK
[![version](https://img.shields.io/github/release/openfactoryio/openfactory-core.svg?color=blue)](https://github.com/openfactoryio/openfactory-sdk/releases)
[![OpenFactory SDK Feature](https://img.shields.io/badge/devcontainer-feature-blue?logo=visualstudiocode)](https://github.com/openfactoryio/openfactory-sdk/tree/main/.devcontainer/features)
![License](https://img.shields.io/github/license/openfactoryio/openfactory-sdk?style=flat-square)

**OpenFactory Software Development Kit**

The **OpenFactory-SDK** provides tools to develop and test [OpenFactory](https://github.com/openfactoryio) applications in a simplified development environment. Instead of requiring a full OpenFactory and Kafka cluster setup, this SDK uses lightweight Docker containers to simulate the necessary infrastructure.

The SDK is delivered as a set of **Dev Container Features** that can be easily added to your development environment.

## 🛠 Features

Currently, the SDK provides the following Dev Container features:

| Feature ID        | Description                                                       |
| ----------------- | ----------------------------------------------------------------- |
| `infra`           | Simulates the OpenFactory infrastructure (Kafka Cluster + ksqlDB) |
| `opcua-connector` | Deploys an OpenFactory OPC UA Connector for application testing   |
| `nfs-server`      | Provides a mocked NFS server for shared filesystem testing        |

Each feature can be configured independently and further combined, depending on your development needs.

## 🐳 Using OpenFactory-SDK in a Dev Container

Once installed, the features allow you to start and stop infrastructure and OPC UA Connector services via shell aliases.

| Feature           | Start Command        | Stop Command           |
| ----------------- | -------------------- | ---------------------- |
| OpenFactory Infra | `spinup`             | `teardown`             |
| OPC UA Connector  | `opcua-connector-up` | `opcua-connector-down` |
| Mocked NFS Server | `nfs-start`          | `nfs-stop`             |


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
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/openfactoryio/openfactory-sdk/infra:0.5.5": {},
    "ghcr.io/openfactoryio/openfactory-sdk/opcua-connector:0.5.5": {},
    "ghcr.io/openfactoryio/openfactory-sdk/nfs-server:0.5.5": {}
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
| `nfs-server`      | `nfs-mountpoint`          | Path exported by the mocked NFS server                          | string  | `/ofa/nfsvolume`            |
|                   | `nfs-uid`                 | UID owning the exported NFS mountpoint                          | string  | `1200`                      |
|                   | `nfs-gid`                 | GID owning the exported NFS mountpoint                          | string  | `1200`                      |

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
  OPENFACTORY_VERION=<value of feature option id openfactory-version>
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

**Mocked NFS Server (`nfs-server`) Feature:**

* Install helper scripts to manage a mocked NFS server
* Create a mocked NFS server container using Docker
* Create a persistent Docker volume for NFS data
* Define environment variables:

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


## Quick start

0. Assurez vous d'avoir Docker d'installé. Aussi, pour pouvoir ouvrir OpenFactory sur une machine Windows, il faut d'abord s'assurer d'avoir WSL2 (assurez vous de l'installer **séparément** de l'installation wsl docker afin d'avoir accès à l'environnement Ubuntu). Le devcontainer doit être ouvert à partir d'un environnement Linux/Unix pour qu'il fonctionne (faites 'reopen in container' pour ouvrir le devcontainer).

1. Si OpenFactory était déjà ouvert précédemment et les containers n'ont pas pu fermer correctement, vous pouvez commencer par faire `teardown` et `opcua-connector-down` pour s'assurer de commencer avec un proejt clean.

2. Pour démarrer OpenFactory, exécuter la commande `spinup` et `opcua-connector-up`. La commande spinup permet de démarrer l'infrastructure d'OpenFactory et opcua-connector-up permet de démarrer le container qui écoute les données du serveur OPC-UA venant du device.

3. Pour connecter un adaptateur ou un équipement à OpenFactory, il faut définir la connection à l'adaptateur/équipement dans un fichier .yml de la façon suivante:
```
devices:
  <NomDevice>>:
    uuid: <NomDevice>

    connector:
      type: opcua

      server:
        uri: opc.tcp://<AdresseIPServeurOPCUA>:<PORTServeurOPCUA>

      variables:
        <NomVariable>:
          browse_path: 0:Root/0:Objects/2:<NomDevice>/2:<NomVariable>
          tag: <NomDevice>.<NomVariable>

      methods:
        <NomMéthode>:
          browse_path: 0:Root/0:Objects/2:<NomDevice>/2:<NomMéthode>
        
```
Puis pour le démarrer, il faut rouler la commande `ofa device up <path_fichier_yml>`

4. De la même façon, pour rouler une application native à OpenFactory, il faut la définir dans un fichier yml, de cette façon:
```
apps:
  <NomApp>:
   uuid: <UUID-APP> (choix arbitraire)
   image: <NomImageDocker>
   networks:
    - factory-net
```
Puis, pour la démarrer, il faut rouler la commande `ofa apps up <path_fichier_yml>`

5. Pour arrêter correctement OpenFactory, il faut exécuter la commande `teardown` ainsi que `opcua-connector-down`. S'il y a des containers d'apps ou d'adapters/devices qui ont été pulled à l'extérieur de OpenFactory, il faut les enlever manuellement (soit par `docker kill $(docker ps -q)` ou avec l'extension containers de VSCode)

### Cas d'utilisation: accéder aux données simulées de la CNC par l'API websockets

1. Pour démarrer tous les components nécessaires à la connection à la CNC virtuelle, vous pouvez exécuter `python ./scripts/spinup_cnc.py`à partir du root du projet. 

2. Pour s'assurer du bon fonctionnement de l'API et visualiser les données venant de la CNC virtuelle, vous pouvez exécuter `python dummy_client.py` pour avoir la liste des équipements disponibles, puis `python dummy_client.py cnc` pour avoir les mises à jour en temps réel les données de la CNC.  ** Il faut s'assurer que websockets soit installé sur l'environnement avant de lancer le script avec `pip install websockets`.