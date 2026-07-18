# Step 3 — Add one agent and a few tools

**Goal:** an agent running on the box that talks to the models *through your gateway*, and can call a small set of tools over MCP. Three tools you use, not thirty you configured and forgot.

> Principle: *The fabric is the product.* The tools are the asset; the model is a tenant. Decouple them so any agent, present or future, can call the same set. See `PRINCIPLES.md`.

We use **Claude Code** as the agent. Any MCP-capable agent works the same way — the pattern is what matters.

---

## 3.1 Install Claude Code

On the box:

```
curl -fsSL https://claude.ai/install.sh | bash
```

This is Anthropic's recommended native installer — no Node.js required, and it auto-updates in the background. (Prefer npm? `npm install -g @anthropic-ai/claude-code` pulls the same binary. On a Windows machine you'd run `irm https://claude.ai/install.ps1 | iex` instead — but this build runs on your Linux box, so the curl form above is the one.)

It needs a **paid Anthropic account** (Pro, Max, or API credits on the Console) — the free Claude.ai plan doesn't include Claude Code. This is the model subscription line from the essay's cost breakdown; budget for it.

- Claude Code docs (overview, install, settings): https://code.claude.com/docs
- Anthropic plans and pricing: https://www.anthropic.com/pricing
- Get API credits / console: https://console.anthropic.com/

## 3.2 Point it at your gateway, not straight at Anthropic

So every call runs through the one endpoint you control (and shows up in the gateway's logs). Set these on the box (add to `~/.bashrc` to persist):

```
export ANTHROPIC_BASE_URL="http://<TAILSCALE_IP>:4000"
export ANTHROPIC_AUTH_TOKEN="<your-litellm-master-key>"
```

Now Claude Code sends its requests to LiteLLM, which routes to the actual provider. Swap models by changing the gateway config, not the agent.

- Claude Code settings & environment variables: https://code.claude.com/docs (see Settings)

## 3.3 Give it three tools over MCP

MCP (Model Context Protocol) is the open standard agents use to call tools. Start with a filesystem tool (so the agent can read/write your project and, next step, your vault) and GitHub. Copy `agent/mcp.example.json` to the location Claude Code reads, or use the CLI:

```
claude mcp add filesystem
claude mcp add github
```

Add the **third** tool you'll actually use this month and stop.

- Connect MCP servers (quickstart): https://code.claude.com/docs/en/mcp-quickstart
- MCP standard: https://modelcontextprotocol.io
- Reference servers (filesystem, git, etc.): https://github.com/modelcontextprotocol/servers
- Official GitHub MCP server: https://github.com/github/github-mcp-server

---

## ✅ Verification (must pass before Step 4)

```
claude mcp list     # shows filesystem, github — status connected
```

Then start Claude Code and ask it something that needs a tool, e.g. *"list the files in this directory"* (filesystem) or *"what repos can you see?"* (github). Look for the tool call in its output.

Confirm it's routing through the gateway: run a prompt, then check the gateway saw it —

```
docker logs $(docker ps -qf name=litellm) --tail 20
```

You should see the request in LiteLLM's logs. If the agent works **and** the call appears at the gateway, Step 3 is done. One agent, three tools, every model call flowing through a single observable door.
