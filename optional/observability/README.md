# OPTIONAL — Observability

> ⚠️ **This is not part of the weekend build. Do not start here.**
> Stand up the foundation (Steps 0–4) and live in it first. Add this only once you
> have services worth watching. A monitoring stack with nothing to monitor is the
> exact over-engineering this whole design avoids (see `../../PRINCIPLES.md` #7 and
> `../../docs/grow-into.md`).

## Why it's optional, and outside the core

Principle 7 says *observe everything* — but "everything" is meaningful only once
there's something running. Standing up Grafana + Prometheus before you have a
gateway and an agent to watch is premature: it's cost and complexity with no
payload yet. So this lives in `optional/`, deliberately fenced off. When your box
is actually doing work — the gateway routing calls, containers serving things —
come back and turn this on.

## When to turn it on

Good signals: you've caught yourself running `docker logs` by hand more than
twice; you want to see model spend and latency across providers; you're serving
something and need to know when it breaks. That's the moment. Not before.

## What's here

A minimal stack, bound to the tailnet like everything else:

- **Prometheus** — scrapes metrics (LiteLLM exposes `/metrics`; enable it in the gateway config).
- **Grafana** — dashboards over Prometheus. Start with one dashboard: gateway request rate, latency, error rate, spend.

(Logs via **Loki** are a natural next add; left out here to keep the first step small. See links below.)

## Run it

From the repo root, after the gateway is up:

```
make observability
# or:
cd optional/observability && docker compose --env-file ../../.env up -d
```

Grafana comes up on `${TAILSCALE_IP}:3000` — **tailnet only**, never `0.0.0.0`.
Set `GRAFANA_ADMIN_PASSWORD` in `.env` first. Then add Prometheus
(`http://prometheus:9090`) as a data source and build the one dashboard you need.

To wire the gateway in: enable Prometheus metrics in LiteLLM
(`litellm_settings: callbacks: ["prometheus"]` in `gateway/litellm.config.yaml`)
so `/metrics` is scrapeable.

## Docs

- Grafana — https://grafana.com/docs/grafana/latest/
- Grafana via Docker — https://grafana.com/docs/grafana/latest/setup-grafana/installation/docker/
- Prometheus — https://prometheus.io/docs/
- Loki (logs, later) — https://grafana.com/docs/loki/latest/
- LiteLLM Prometheus metrics — https://docs.litellm.ai/docs/proxy/prometheus
