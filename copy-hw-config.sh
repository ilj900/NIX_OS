#!/usr/bin/env bash
set -euo pipefail
 
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
 
if [ ! -f /etc/nixos/hardware-configuration.nix ]; then
  echo "==> No hardware-configuration.nix found, generating one"
  sudo nixos-generate-config
fi

echo "==> Copying the hardware config"
sudo cp /etc/nixos/hardware-configuration.nix "$REPO_DIR/hardware-configuration.nix"
sudo chown "$USER" "$REPO_DIR/hardware-configuration.nix"