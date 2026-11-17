---
title: "Step 1 — Lock the edge"
sidebarTitle: "1. Lock the edge"
description: "Put the box on a private Tailscale mesh and close every public port except SSH, before any service is installed."
---

**Goal:** the box is reachable from your own devices over a private mesh, and **nothing** is exposed to the open internet except the one SSH door. Do this *before* installing any services.

> Principle: *Zero ingress.* You don't secure a box by listing what to block. You expose nothing, then open one hole you control. See `PRINCIPLES.md`.

There's a script that does all of this idempotently: `scripts/lock-edge.sh`. Read it, then run it — or follow the steps below by hand so you understand each one.

---

## 1.1 Put the box on a private mesh (Tailscale)

Tailscale builds an encrypted WireGuard network between your machines. Your laptop, phone, and this box all get stable private IPs and can reach each other from anywhere — without opening a single public port.

On the box:

```
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

`tailscale up` prints a URL — open it in your browser and sign in to authorize the box. The free personal plan covers this build.

Get the box's tailnet IP (starts with `100.`), you'll use it everywhere:

```
tailscale ip -4
```

Install Tailscale on your laptop and phone too (same account) so they're on the mesh.

- Install on Linux: https://tailscale.com/kb/1031/install-linux
- `tailscale up` and the CLI: https://tailscale.com/kb/1080/cli
- Download for every platform: https://tailscale.com/download

## 1.2 Close the public surface (ufw)

Now deny everything inbound except SSH, which we keep temporarily so you can't lock yourself out:

```
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw enable
```

`ufw enable` will warn that it may disrupt SSH — it won't, because you just allowed port 22. Type `y`.

- ufw guide (Ubuntu): https://documentation.ubuntu.com/server/how-to/security/firewalls/
- ufw community reference: https://help.ubuntu.com/community/UFW

## 1.3 The Docker gotcha (know this now, before Step 2)

**Docker bypasses ufw.** When you install Docker in Step 2 and publish a container port, Docker writes its own iptables rules *underneath* ufw, so a container you thought was firewalled can be world-reachable. The fix used throughout this build is simple and reliable: **never publish a container to `0.0.0.0`. Always bind to the Tailscale IP.**

So in every compose file you'll see ports written as:

```
ports:
  - "100.x.y.z:4000:4000"     # tailnet IP only, never 0.0.0.0:4000
```

That keeps the service on the mesh even though Docker sidesteps ufw. (There are heavier fixes like `ufw-docker`, but binding to the tailnet is enough for a single box.)

## 1.4 Lock SSH to the mesh (recommended)

Once you've confirmed you can reach the box over Tailscale (`ssh ubuntu@100.x.y.z`), you can remove the public SSH rule so even port 22 is only reachable on the tailnet:

```
sudo ufw delete allow 22/tcp
```

Now the box has **zero** open public ports. You reach it exclusively over the mesh. (Keep the OCI/Hetzner web console as your break-glass access.)

---

## ✅ Verification (must pass before Step 2)

From your laptop (on Tailscale):

```
ssh -i ~/.ssh/own_the_house ubuntu@<TAILSCALE_IP>   # you're in over the mesh
```

On the box:

```
sudo ufw status verbose      # Status: active; default deny incoming
tailscale status             # box + your laptop/phone listed
ss -tlnp | grep -v 127.0.0.1 # nothing listening on 0.0.0.0 you didn't intend
```

If you can reach the box over the `100.` address and ufw shows default-deny, the edge is locked. This is the load-bearing step — everything else sits behind it.
