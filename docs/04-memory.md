---
title: "Step 4 — Give it memory"
sidebarTitle: "4. Memory"
description: "Give the agent a notes vault it reads and writes, so the system keeps what it learns between sessions."
---

**Goal:** a place on the box the agent reads from and writes to, so the system learns across sessions even though the model remembers nothing. This is the seed of the substrate — the part that still matters three model generations from now.

> Principle: *Memory is what compounds.* The models reset. The house keeps notes. See `PRINCIPLES.md`. This is the step most people skip, and it's the only one that accrues value. Don't skip it.

---

## 4.1 Make a vault

An [Obsidian](https://obsidian.md) vault is ideal because it's just a folder of Markdown — plain files you own, no lock-in — and you can open the same folder in the Obsidian app for a human view. But a bare directory of `.md` works fine to start.

On the box:

```
mkdir -p ~/house/memory/decisions
```

This repo ships a starter under `memory/` you can copy in, including a decision-note template (`memory/decisions/0000-decision-template.md`). Decisions are the highest-value thing to record: what you chose, why, and what you rejected. An agent that can read your past decisions stops re-litigating them.

- Obsidian: https://obsidian.md — Help: https://help.obsidian.md

## 4.2 Point the filesystem MCP server at it

In Step 3 you added a filesystem tool. Scope it to the vault so the agent can read and write notes there. With Claude Code, add the vault path as an allowed directory for the filesystem server (see the server's README):

- Filesystem MCP server (allowed directories, config): https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem

The point is the **loop**: the agent learns something during a session, writes a note, and reads it back next time. Wire that loop and the house starts keeping its own records.

## 4.3 Use it

Two habits make the memory real:

1. **End sessions by writing back.** Ask the agent to log what was decided or learned into `memory/` before you close it.
2. **Start sessions by reading.** Have the agent skim recent notes for the project you're working on so it walks in with context.

Everything after this — a knowledge base, retrieval, embeddings — is an elaboration of this one loop. Start with plain files.

---

## ✅ Verification (the foundation is complete)

```
ls ~/house/memory/decisions        # your vault exists
```

Then, in the agent: ask it to **write** a short note into the vault ("record a decision that we chose LiteLLM as the gateway, because it makes model choice a config change"), close the session, start a new one, and ask it to **read** that note back. If it can write and later read, the loop is closed.

That's the weekend: a locked edge, a model gateway, one agent, three tools, and a memory. Every one of the seven principles is now load-bearing. **Stop here and live in it for a while** before adding more — see `docs/grow-into.md` for what comes next and in what order.
