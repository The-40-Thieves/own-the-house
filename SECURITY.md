# Security model — one door

This build's security posture is a single sentence: **nothing on the box is reachable from the open internet except one SSH door, and even that is best kept on the private mesh.** Everything else is a consequence of that.

## The threat model

You are one person running one box. You are not defending a fleet; you are shrinking the attack surface until there's almost nothing to attack.

- **No inbound ports.** After Step 1, `ufw` defaults to deny-incoming and the only allowed port is SSH — which you then move onto the Tailscale mesh so it isn't public either. An attacker on the open internet has nothing to connect to.
- **Identity, not exposure.** You reach the box over Tailscale, which authenticates devices against your account. Access is a function of who you are, not what port is open.
- **Outbound tunnels for anything public.** When you eventually serve a public site, it goes through a tunnel that dials *out* (e.g. Cloudflare Tunnel). The box never accepts an inbound connection; there's still no port to attack.

## The one gotcha that breaks it: Docker

Docker bypasses `ufw` by writing its own iptables rules. Publish a container to `0.0.0.0` and it can be world-reachable even though `ufw` says deny-all. **Every service in this repo binds to the Tailscale IP, never `0.0.0.0`.** If you add a container, do the same. This single rule is what keeps zero-ingress true in practice.

## Secrets

- API keys and tokens live in `.env`, which is git-ignored. Never commit it. Never paste a key into an AI chat.
- Your SSH private key stays on your laptop. Only the public key goes to the cloud provider.
- `LITELLM_MASTER_KEY` is the credential your tools present to the gateway. Make it long and random; rotate it if it leaks.

## If you suspect compromise

Rotate provider keys (Anthropic / Groq / OpenAI consoles) and `LITELLM_MASTER_KEY`, rebuild the box from the configs in this repo (that's what principle 6 buys you), and re-run `scripts/preflight.sh` to confirm the invariants hold.

## Reporting

This is a personal-infrastructure template, not a hosted service. If you find an issue in the *template* (a config that leaks by default, a doc that tells you to open a port), open an issue on the repo.
