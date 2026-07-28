#!/usr/bin/env bash
set -euo pipefail
 
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
 
echo "==> Ensuring scripts are executable"
chmod +x "$REPO_DIR"/*.sh

"$REPO_DIR/copy-hw-config.sh"
 
echo "==> Building system"
sudo nixos-rebuild switch -I nixos-config="$REPO_DIR/configuration.nix"