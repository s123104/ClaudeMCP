#!/usr/bin/env bash
set -euo pipefail

CONF_DIR="/etc/docker"
CONF_FILE="$CONF_DIR/daemon.json"

sudo mkdir -p "$CONF_DIR"

if [ -f "$CONF_FILE" ]; then
  echo "🔄 併入現有 daemon.json ..."
  sudo jq -s '.[0] * .[1]' "$CONF_FILE" docker/daemon-userns.json | sudo tee "$CONF_FILE" >/dev/null
else
  echo "🆕 產生 daemon.json ..."
  sudo cp docker/daemon-userns.json "$CONF_FILE"
fi

echo "♻️  重新啟動 Docker..."
sudo systemctl restart docker
echo "✅ userns-remap 已啟用！"
