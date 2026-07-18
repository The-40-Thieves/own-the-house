# own-the-house

**Stand up your own single-host AI substrate in a weekend. One small box. Real tools. No data center.**

You rent the model. You own the house. This repo is the buildable companion to that idea: a guided runbook that takes you from an empty cloud instance to a locked-down box running a model gateway, a coding agent, a handful of tools, and a memory that compounds — the part of an AI setup that stays yours when the models change.

It is designed to be **run with an AI agent**. Hand the repo to Claude, ChatGPT, Gemini, Grok, or a local model and have it walk you through, one verified step at a time. Start with **[AGENTS.md](./AGENTS.md)**.

---

## What you end up with

A single Ubuntu 24.04 ARM box on which:

- **Nothing faces the open internet** except one SSH door; everything lives on a private [Tailscale](https://tailscale.com) mesh.
- **One gateway** ([LiteLLM](https://litellm.ai)) fronts every model provider, so switching models is one line of config.
- **An agent** ([Claude Code](https://code.claude.com/docs), or your choice) reaches the models through that gateway and calls a small set of tools over [MCP](https://modelcontextprotocol.io).
- **A memory** — a notes vault the agent reads and writes — that gets smarter every session even though the model has none.

The box is free (Oracle Always Free ARM) or a few euros a month (Hetzner). The only real recurring cost is your model subscription.

---

## Quickstart

You don't run these in order by hand — you give them to your agent and let it guide you. But here's the shape:

```
0. Provision the box        docs/00-provision-oci.md
1. Lock the edge            docs/01-lock-the-edge.md      scripts/lock-edge.sh
2. Put up the gateway       docs/02-gateway.md            gateway/
3. Add an agent + tools     docs/03-agent-and-tools.md    agent/
4. Give it memory           docs/04-memory.md             memory/
```

Verify at each step with `scripts/preflight.sh`. Copy `.env.example` to `.env` and fill in your keys (never commit it).

---

## Repository map

```
own-the-house/
├─ AGENTS.md              # start here — the LLM runbook
├─ README.md              # this file
├─ PRINCIPLES.md          # the 7 principles the build is shaped by
├─ WHEN-NOT-TO.md         # when a single box is the wrong answer (read this)
├─ SECURITY.md            # the zero-ingress threat model
├─ LICENSE                # Apache-2.0
├─ .env.example           # provider keys + settings, placeholders only
├─ .gitignore             # keeps secrets and machine state out of git
├─ Makefile               # make edge / gateway / agent / verify
├─ docs/                  # one file per step, with official doc links
│  ├─ 00-provision-oci.md
│  ├─ 01-lock-the-edge.md
│  ├─ 02-gateway.md
│  ├─ 03-agent-and-tools.md
│  ├─ 04-memory.md
│  ├─ grow-into.md        # what to add later, and in what order
│  └─ links.md            # every official product doc, in one place
├─ scripts/
│  ├─ lock-edge.sh        # Tailscale + ufw, idempotent
│  └─ preflight.sh        # verifies the invariants hold
├─ gateway/               # LiteLLM: compose + config
├─ agent/                 # MCP tool config for the agent
├─ memory/                # the vault seed + a decision-note template
├─ optional/
│  └─ observability/      # OPTIONAL module — add only when you need it
└─ assets/                # diagrams
```

## Scope, on purpose

This repo builds the **foundation only**: edge, gateway, agent, tools, memory. It deliberately stops there. Observability is shipped as a clearly labeled optional module (`optional/observability/`) rather than in the core, because standing up a monitoring stack before you have services to watch is exactly the over-engineering this design avoids. Grow into the rest as need pulls it in — see `docs/grow-into.md`.

## License

Apache-2.0. The pattern is yours: fork it, adapt it, strip it to the studs. See [LICENSE](./LICENSE).
