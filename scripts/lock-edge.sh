#!/usr/bin/env bash
# lock-edge.sh — put the box on Tailscale and close every public port but SSH.
# Idempotent: safe to run more than once. Run on the BOX, not your laptop.
#   bash scripts/lock-edge.sh
# See docs/01-lock-the-edge.md for the why behind each step.
set -euo pipefail

echo "==> Step 1: Tailscale"
if ! command -v tailscale >/dev/null 2>&1; then
  echo "Installing Tailscale..."
  curl -fsSL https://tailscale.com/install.sh | sh
else
  echo "Tailscale already installed."
fi

if ! tailscale status >/dev/null 2>&1; then
  echo "Bringing Tailscale up — a browser auth URL will print. Authorize this box."
  sudo tailscale up
else
  echo "Tailscale already up."
fi

TS_IP="$(tailscale ip -4 2>/dev/null | head -n1 || true)"
echo "Tailscale IP: ${TS_IP:-<not yet assigned>}"

echo "==> Step 2: ufw (deny all inbound except SSH)"
sudo ufw --force default deny incoming
sudo ufw --force default allow outgoing
sudo ufw allow 22/tcp
sudo ufw --force enable
sudo ufw status verbose

cat <<EOF

==> Edge locked.
Next:
  1. Confirm you can reach this box over the mesh:  ssh <user>@${TS_IP:-<tailscale-ip>}
  2. Once that works, you may remove public SSH so even port 22 is mesh-only:
        sudo ufw delete allow 22/tcp
  3. Verify with:  bash scripts/preflight.sh
Reminder: bind every future service to ${TS_IP:-<tailscale-ip>}, never 0.0.0.0.
EOF
