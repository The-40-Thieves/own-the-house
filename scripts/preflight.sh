#!/usr/bin/env bash
# preflight.sh — verify the invariants this build depends on. Run on the BOX.
#   bash scripts/preflight.sh
# Exits non-zero if a core check fails. This is principle 7 made executable:
# don't assert the box is safe — check it.
set -uo pipefail

pass=0; fail=0
ok()   { echo "  [ ok ] $1"; pass=$((pass+1)); }
bad()  { echo "  [FAIL] $1"; fail=$((fail+1)); }

echo "== Tailscale =="
if command -v tailscale >/dev/null 2>&1 && tailscale status >/dev/null 2>&1; then
  ok "tailscale is up ($(tailscale ip -4 2>/dev/null | head -n1))"
else
  bad "tailscale not up"
fi

echo "== Firewall =="
if command -v ufw >/dev/null 2>&1 && sudo ufw status verbose 2>/dev/null | grep -q "Status: active"; then
  ok "ufw active"
  if sudo ufw status verbose 2>/dev/null | grep -qi "deny (incoming)"; then
    ok "default deny incoming"
  else
    bad "default incoming is not deny"
  fi
else
  bad "ufw not active"
fi

echo "== Public listeners =="
# Anything bound to 0.0.0.0 / :: is a potential public exposure.
PUB="$(ss -tlnH 2>/dev/null | awk '{print $4}' | grep -E '^(0\.0\.0\.0|\[::\]|\*):' || true)"
if [ -z "$PUB" ]; then
  ok "nothing listening on 0.0.0.0 / ::"
else
  bad "services bound to all interfaces (should be tailnet-only):"
  echo "$PUB" | sed 's/^/         /'
fi

echo "== Gateway (if running) =="
if command -v docker >/dev/null 2>&1 && docker ps --format '{{.Names}}' 2>/dev/null | grep -q litellm; then
  ok "litellm container is running"
else
  echo "  [info] litellm not running yet (fine before Step 2)"
fi

echo
echo "Passed: $pass   Failed: $fail"
[ "$fail" -eq 0 ] && echo "Invariants hold." || { echo "Fix the failures above before continuing."; exit 1; }
