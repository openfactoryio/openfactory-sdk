# OpenFactory Grafana Dev Container Feature

Installs **Grafana and OpenFactory observability tools** inside your Dev Container.

## 📊 Deploy Grafana

Once installed, the feature allows you to deploy Grafana for monitoring OpenFactory.

Start the Grafana services:

```bash
grafana-up
```

Stop the Grafana services:

```bash
grafana-down
```

Note: The intial loggin / password for Grafana is: `admin` / `admin`.

## 📝 Deploy Logging

The feature also provides centralized logging using Loki and Alloy.

Start the logging services:

```bash
logging-up
```

Stop the logging services:

```bash
logging-down
```

A Grafana dashboard for exploring logs is predefined.

## 🚀 Usage

Add the Grafana feature to your `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:4.0.0": {},
    "ghcr.io/openfactoryio/openfactory-sdk/infra:0.6.5": {},
    "ghcr.io/openfactoryio/openfactory-sdk/grafana:0.6.5": {}
  },
  "forwardPorts": [3000, 9090, 12345]
}
```

> 💡 **Tip:** Version pinning ensures compatibility with the OpenFactory Core version running in your factory.

The following services are then available:

* Grafana on port `3000`
* Prometheus on port `9090`
* Grafana Alloy on port `12345`

---

## ✅ What This Feature Does

* Copies the OpenFactory Grafana configuration files to `/usr/local/share/openfactory-grafana`.

* Preconfigures the following Grafana datasources:

  * **Prometheus** at `http://prometheus:9090`
  * **Loki** at `http://loki:3100`

* Provides a predefined Grafana dashboard for logging.

* Adds these shell aliases:

  ```bash
  grafana-up      # Launch Grafana and Prometheus
  grafana-down    # Stop Grafana and Prometheus
  logging-up      # Launch Loki and Alloy
  logging-down    # Stop Loki and Alloy
  ```

## 🧪 For Feature Developers

If you're contributing to this feature, you may want to install it from the local source.

Example `.devcontainer/devcontainer.json`:

```json
{
  "features": {
    "./features/grafana": {}
  }
}
```
