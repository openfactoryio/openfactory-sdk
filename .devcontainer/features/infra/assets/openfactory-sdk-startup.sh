#!/usr/bin/env bash
#
# ------------------------------------------------------------------------------
# OpenFactory DNS Setup (Container Startup Script)
# ------------------------------------------------------------------------------
# This script configures local DNS resolution inside the devcontainer using
# dnsmasq. It enables resolution of *.openfactory.local domains to the container
# itself, allowing services (e.g. Traefik-routed apps) to be accessed via
# human-readable hostnames.
#
# What it does:
# - Installs dnsmasq if not already present
# - Configures dnsmasq to resolve:
#       *.openfactory.local → CONTAINER_IP
# - Preserves existing upstream DNS servers from /etc/resolv.conf
# - Starts dnsmasq (idempotent, safe to run multiple times)
# - Updates /etc/resolv.conf to use local DNS (127.0.0.1)
#
# Why:
# - Enables URLs like:
#       http://myapp.openfactory.local
#   to resolve inside the container
# - Required for host-based routing via Traefik
# - Works alongside path-based routing (localhost/<app>)
#
# Requirements:
# - CONTAINER_IP must be set (injected via profile.d during container startup)
# - User must have sudo privileges if not running as root
#
# Notes:
# - Designed for devcontainer environments (not production)
# - Avoids hardcoding public DNS (uses system-provided upstream DNS)
# - Safe to re-run (idempotent configuration)
#
# ------------------------------------------------------------------------------

set -e

echo "🔧 OpenFactory startup: configuring dnsmasq..."

# Ensure CONTAINER_IP exists
if [ -z "$CONTAINER_IP" ]; then
  echo "❌ CONTAINER_IP is not set"
  exit 1
fi

# Determine privilege escalation
if [ "$(id -u)" -ne 0 ]; then
  SUDO="sudo"
else
  SUDO=""
fi

DNSMASQ_CONF_DIR="/etc/dnsmasq.d"
DNSMASQ_CONF_FILE="${DNSMASQ_CONF_DIR}/openfactory.conf"

# Ensure dnsmasq is installed (safe guard, ideally done in install.sh)
if ! command -v dnsmasq >/dev/null 2>&1; then
  echo "📦 Installing dnsmasq..."
  $SUDO apt-get update -y
  $SUDO apt-get install -y dnsmasq
fi

# Create config directory
$SUDO mkdir -p "$DNSMASQ_CONF_DIR"

# Capture upstream DNS ----
UPSTREAM_DNS=$(grep -E '^nameserver' /etc/resolv.conf | awk '{print $2}' | grep -v '^127\.0\.0\.1$')

# Write dnsmasq config (idempotent)
$SUDO tee "$DNSMASQ_CONF_FILE" > /dev/null <<EOF
# OpenFactory DNS
address=/openfactory.local/${CONTAINER_IP}

# Listen locally
listen-address=127.0.0.1
bind-interfaces

# Forward everything else to upstream DNS
$(for dns in $UPSTREAM_DNS; do echo "server=$dns"; done)
EOF

echo "✅ dnsmasq config written"

# Start dnsmasq if not already running
echo "🚀 Ensuring dnsmasq is running..."

if $SUDO dnsmasq --test --conf-dir="$DNSMASQ_CONF_DIR" >/dev/null 2>&1; then
  if $SUDO dnsmasq --conf-dir="$DNSMASQ_CONF_DIR" 2>/tmp/dnsmasq.err; then
    echo "✅ dnsmasq started"
  else
    if grep -q "Address already in use" /tmp/dnsmasq.err; then
      echo "ℹ️  dnsmasq already running"
    else
      echo "❌ dnsmasq failed to start:"
      cat /tmp/dnsmasq.err
      exit 1
    fi
  fi
else
  echo "❌ dnsmasq configuration invalid"
  exit 1
fi

# Update resolv.conf safely
if ! grep -q "127.0.0.1" /etc/resolv.conf; then
  echo "🛠️ Updating /etc/resolv.conf..."

  $SUDO cp /etc/resolv.conf /etc/resolv.conf.openfactory.bak || true

  $SUDO tee /etc/resolv.conf > /dev/null <<EOF
nameserver 127.0.0.1
EOF

  echo "✅ resolv.conf updated"
else
  echo "ℹ️  resolv.conf already configured"
fi

echo "🎉 OpenFactory DNS setup complete"
