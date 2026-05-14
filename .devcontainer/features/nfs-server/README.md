# OpenFactory NFS Server Dev Container Feature

Installs a mocked NFS server utility inside your Dev Container for use with the OpenFactory SDK.

## 🐳 Deploy OpenFactory Mocked NFS Server

Once installed, the feature allows you to start a mocked NFS server suitable for testing OpenFactory applications requiring shared NFS storage.

Start the mocked NFS server:

```bash
nfs-start
```

Stop and remove the mocked NFS server:

```bash
nfs-stop
```

The NFS server is deployed as a Docker container inside your development environment.

---

## 🚀 Usage

This section describes how to configure the feature in your devcontainer depending on your use case.

> ⚠️ **Prerequisite:** This feature requires Docker support inside the Dev Container.
> Use the `docker-in-docker` Dev Container feature.

### 1️⃣ OpenFactory Application Developers

Application developers building OpenFactory applications should **pin the SDK feature version** to match the OpenFactory version running in their factory.

Example configuration:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/openfactoryio/openfactory-sdk/nfs-server:0.5.4": {}
  }
}
```

> 💡 **Tip:** Version pinning ensures compatibility with the OpenFactory Core version running in your factory.

### 2️⃣ OpenFactory Core Developers

Core developers contributing to OpenFactory usually want the **latest development version** of the SDK feature.

Example configuration:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/openfactoryio/openfactory-sdk/nfs-server:0.0.0-dev.05580d9": {}
  }
}
```

> 📝 **Note:** The latest development version of the SDK feature can be found at [OpenFactory SDK Container Registry](https://github.com/openfactoryio/openfactory-sdk/pkgs/container/openfactory-sdk%2Fnfs-server?utm_source=chatgpt.com)

---

## ⚙️ Optional Settings

| Option ID        | Description                                                 | Type    | Default Value    |
| ---------------- | ----------------------------------------------------------- | ------- | ---------------- |
| `nfs-mountpoint` | Path exported by the mocked NFS server                      | string  | `/ofa/nfsvolume` |
| `nfs-uid`        | UID owning the exported NFS mountpoint                      | string  | `1200`           |
| `nfs-gid`        | GID owning the exported NFS mountpoint                      | string  | `1200`           |

Example configuration:

```json
{
  "features": {
    "ghcr.io/openfactoryio/openfactory-sdk/nfs-server:0.5.5": {
      "nfs-mountpoint": "/shared/data",
      "nfs-uid": "2100",
      "nfs-gid": "2200"
    }
  }
}
```
This creates an NFS export:
```
/shared/data
```
owned by:
```
UID=2100
GID=2200
```
Applications accessing the NFS export should typically run with the same UID/GID.

---

## ✅ What This Feature Does

* Copies the mocked NFS server utility scripts into:

  ```bash
  /usr/local/share/openfactory-nfs
  ```

* Defines the following environment variables:

  ```bash
  NFS_CONTAINER_NAME=devcontainer-nfs
  NFS_VOLUME_NAME=devcontainer-nfsdata
  NFS_NETWORK_NAME=factory-net

  NFS_MOUNTPOINT=<nfs-mountpoint>
  NFS_UID=<nfs-uid>
  NFS_GID=<nfs-gid>
  ```

* Adds these shell aliases:

  ```bash
  nfs-start   # Start the mocked NFS server
  nfs-stop    # Stop and remove the mocked NFS server
  ```

* Creates a mocked NFS server container using:

  ```bash
  itsthenetwork/nfs-server-alpine
  ```

* Creates a persistent Docker volume for NFS storage:

  ```bash
  devcontainer-nfsdata
  ```

---

## 📦 Mounting the NFS Export

After starting the mocked NFS server:

```bash
nfs-start
```

the utility displays:

* the NFS server IP
* the exported mountpoint
* the UID/GID owning the export

You can mount the export from another container or from the Dev Container itself using:

```bash
sudo mount -t nfs <NFS_SERVER_IP>:<NFS_MOUNTPOINT> /your/local/mountpoint
```

Example:

```bash
sudo mount -t nfs 172.18.0.5:/ofa/nfsvolume /mnt/nfs
```

> ⚠️ Applications accessing the NFS export should typically run with the same UID/GID configured for the export.

---

## 🧪 For Feature Developers

If you're contributing to this feature, you may want to install it from the local source during development.

Example `.devcontainer/devcontainer.json`:

```json
{
  "features": {
    "./features/nfs-server": {}
  }
}
```

When developing locally, you may also want Bash terminals to automatically source `/etc/profile.d` scripts:

```json
{
  "customizations": {
    "vscode": {
      "settings": {
        "terminal.integrated.defaultProfile.linux": "bash-login",
        "terminal.integrated.profiles.linux": {
          "bash-login": {
            "path": "/bin/bash",
            "args": ["-l"]
          }
        }
      }
    }
  }
}
```

This ensures feature environment variables such as:

```bash
$NFS_UID
$NFS_GID
$NFS_MOUNTPOINT
```

are immediately available in newly opened VS Code terminals.
