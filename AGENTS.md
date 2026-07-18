# AGENTS.md — Run this build with an AI agent

This repository is a **guided runbook**. It is written to be handed to an LLM (Claude, ChatGPT, Gemini, Grok, a local model, whatever you use) so the model can walk you through standing up your own single-host AI substrate, one verified step at a time.

You do not need to be an infrastructure engineer. You need a terminal, about a weekend, and a model to pair with.

---

## For the human: how to start

1. Open your AI assistant of choice.
2. Give it this instruction, then paste the contents of this file (and, when asked, the file for the current step):

> "You are my build guide. Follow AGENTS.md in the `own-the-house` repo. Take me through it one step at a time. Do not skip ahead. After each step, run the verification with me and wait until it passes before continuing. Explain what each command does before I run it. Never ask me to paste a secret into the chat."

3. Work top to bottom through the steps below. Each step has its own doc in `docs/`.

If your assistant can read files or browse a repo directly, point it at this folder instead of pasting.

---

## For the agent: operating rules

You are guiding a human through a real infrastructure build on their own machines. Hold to these rules:

**Gate every step.** Do the steps in order. Do not move to step N+1 until the verification block at the end of step N passes. If it fails, help the user debug *that* step before proceeding.

**Explain before executing.** Before any command, say in one or two sentences what it does and what to expect. Prefer commands the user runs themselves in their own terminal. You are a guide, not an autonomous operator, unless the user has explicitly given you a tool to run commands on the box.

**Never handle secrets in chat.** API keys, tokens, and private keys are entered by the user directly into files or prompts on their machine, never pasted into the conversation. If a step needs a key, tell the user where to get it (links are in `docs/links.md`) and where it goes, and stop there.

**Zero ingress is the invariant.** The security posture of this build is: nothing on the box is reachable from the open internet except one SSH door, and even that is best kept on the private mesh. If any step would open a public port, stop and flag it. Bind services to the Tailscale address, never `0.0.0.0`.

**Reproducibility over cleverness.** Everything should be in a file the user can re-run or roll back. Prefer editing the provided config files over improvising one-off commands.

**Match the user's level.** Ask what OS they're on locally and whether they've used a terminal before. Adjust verbosity accordingly. Assume nothing about their cloud experience.

**When a step stalls, name the failure.** The most common one is OCI "out of capacity" (see `docs/00-provision-oci.md`). Don't let the user think they did something wrong; explain the real cause and the workaround.

---

## The build, in order

| Step | File | What you end with |
|------|------|-------------------|
| 0 | `docs/00-provision-oci.md` | A running Ubuntu 24.04 ARM box (Oracle Always Free, or Hetzner if you'd rather rent) |
| 1 | `docs/01-lock-the-edge.md` | The box on a private Tailscale mesh, firewall closed, nothing public but SSH |
| 2 | `docs/02-gateway.md` | A LiteLLM gateway fronting your model providers on the tailnet |
| 3 | `docs/03-agent-and-tools.md` | Claude Code (or another agent) pointed at the gateway, with three MCP tools |
| 4 | `docs/04-memory.md` | A notes vault the agent reads and writes — the part that compounds |

That is the whole weekend. When those five are done and verified, you have a locked edge, a model gateway, one agent, three tools, and a memory: a real foundation.

**Design doctrine** lives in `PRINCIPLES.md` (why the build is shaped this way) and `WHEN-NOT-TO.md` (when a single box is the wrong answer — read this before you rely on it for anything). Every official product link is collected in `docs/links.md`.

**Do not add more yet.** Observability, more tools, a second agent, GPU bursting — all of that comes *after* the foundation is up and only when a real need pulls it in. The optional observability module in `optional/observability/` is deliberately outside the core for this reason. See `docs/grow-into.md`.

---

## Companion essay

This repo is the buildable companion to the essay "You Rent the Mind. You Own the House." The essay is the why; this repo is the how. You can run the whole thing without reading it, but the principles will make more sense if you do.
