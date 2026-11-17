---
title: "own-the-house"
sidebarTitle: "Overview"
description: "A guided runbook for standing up your own single-host AI substrate in a weekend: one small box, real tools, no data center."
---

You rent the model. You own the house. This guide takes you from an empty cloud instance to a locked-down box running a model gateway, a coding agent, a few tools, and a memory that stays yours when the models change.

The guide is the reading copy of the [own-the-house repository](https://github.com/The-40-Thieves/own-the-house). The scripts, config files and templates that the steps name (such as `scripts/lock-edge.sh` and `gateway/litellm.config.yaml`) live in that repository, so clone it before you start.

## What you end up with

A single Ubuntu 24.04 ARM box on which:

- Nothing faces the open internet except one SSH door. Everything else lives on a private [Tailscale](https://tailscale.com) mesh.
- One gateway ([LiteLLM](https://litellm.ai)) fronts every model provider, so switching models is one line of config.
- An agent reaches the models through that gateway and calls a small set of tools over [MCP](https://modelcontextprotocol.io).
- A notes vault that the agent reads and writes gives the system a memory, even though the model has none.

The box is free on Oracle Always Free ARM, or a few euros a month on Hetzner. The only real recurring cost is your model subscription.

## Run it with an AI agent

The build is designed to be run with an AI assistant as your guide, one verified step at a time. Hand the repository to your assistant and start with [AGENTS.md](https://github.com/The-40-Thieves/own-the-house/blob/main/AGENTS.md).

## The steps

| Step | Page                                          | Files in the repository |
| ---- | --------------------------------------------- | ----------------------- |
| 0    | [Provision the box](/00-provision-oci)        | None                    |
| 1    | [Lock the edge](/01-lock-the-edge)            | `scripts/lock-edge.sh`  |
| 2    | [Put up the gateway](/02-gateway)             | `gateway/`              |
| 3    | [Add an agent and tools](/03-agent-and-tools) | `agent/`                |
| 4    | [Give it memory](/04-memory)                  | `memory/`               |

Check each step with `scripts/preflight.sh` before you move to the next one.

## Read before you build

- [PRINCIPLES.md](https://github.com/The-40-Thieves/own-the-house/blob/main/PRINCIPLES.md) lists the seven principles that shape the build.
- [WHEN-NOT-TO.md](https://github.com/The-40-Thieves/own-the-house/blob/main/WHEN-NOT-TO.md) says when a single box is the wrong answer.
- [SECURITY.md](https://github.com/The-40-Thieves/own-the-house/blob/main/SECURITY.md) describes the zero-ingress threat model.

The build stops at the foundation on purpose. [Grow into it](/grow-into) covers what to add later, and in what order.
