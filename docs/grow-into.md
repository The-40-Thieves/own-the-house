# Grow into it — what to add later, and in what order

The weekend build (Steps 0–4) is the whole foundation. Everything below is optional and should be added **only when a real need pulls it in**, in roughly this order. Adding these early is the over-engineering this design exists to avoid.

## The order

1. **Observability** — once you have services worth watching. Metrics, logs, and traces so you're never guessing what your own box is doing. Shipped here as a clearly labeled optional module: `optional/observability/`. Read its README before you turn it on; the point is that you *don't* start with a monitoring stack.
2. **More tools** — when you hit a wall a new MCP server removes. Add the one that unblocks you, not a catalog.
3. **A second agent / model** — when one model's weakness starts costing you real time. The gateway already makes this a config change.
4. **Databases** — when something needs to persist structured state (a real app, a knowledge base with vectors). Run them in Docker, bound to the tailnet.
5. **A deploy path** — when you're shipping public sites. Serve them through an **outbound tunnel** (e.g. Cloudflare Tunnel / `cloudflared`) so you keep zero ingress: the box dials out, nothing dials in.
6. **GPU, rented by the job** — the first time a task genuinely needs a card. Burst to a serverless GPU backend for the length of the job; don't buy one to idle. See `WHEN-NOT-TO.md` for the exception (24/7 GPU-bound work).

## Things people build on this

- A coding environment any model can drive.
- A private second brain — a knowledge base your agents read and write, on hardware you control.
- A prototype factory with real CI and a real deploy path, no per-experiment cloud bill.
- A research rig that borrows GPU muscle by the minute.
- A self-hosted automation hub — watch a source, summarize, act, notify.
- A place to actually learn infrastructure by running it.

Pick one. The house doesn't care which. That's the point of owning it instead of renting it furnished.

## The rule

Do not front-load the ambitious parts. Do not stand up a monitoring stack before you have three services to monitor. Do not run two deploy controllers because both looked interesting. Do not buy a GPU. Complexity added before you need it isn't a head start — it's debt with no upside yet.
