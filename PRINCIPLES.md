# The seven principles

The tools alone are a pile of parts. These seven make them a house. Learn them and you can make your own choices instead of copying anyone's setup. Only the first is about models at all; the rest is the building.

### 1. Rent the mind. Own the house.
Model choice is a runtime decision, not an architecture decision. Put a gateway in front of every provider so switching models is one line of config, not a rewrite. Everything that calls a model calls the gateway. When the best model changes — and it will — you change a route and nothing downstream notices.
*In this repo:* `gateway/` (Step 2).

### 2. Zero ingress.
Nothing is public except the one door you use to get in. Every service binds to a private network. Public sites are served through a tunnel that dials out, so there are no inbound ports to attack. Don't secure a box by listing what to block — expose nothing, then open one hole you control.
*In this repo:* `scripts/lock-edge.sh`, Step 1, `SECURITY.md`.

### 3. Compute is rented by the job.
Don't buy a GPU to have a GPU. Keep the always-on machine small and cheap. When you need horsepower, rent it for the length of the task and let it disappear. Ownership is for what must persist. A GPU that idles at 3am is not that.
*In this repo:* the box holds no GPU on purpose; see `docs/grow-into.md`.

### 4. The fabric is the product.
The tools are not accessories to the agent. They are the asset. Decouple them so any model, any agent, present or future, can call the same set. The model is a tenant. The tool fabric is the building.
*In this repo:* `agent/` (Step 3), MCP tools independent of the model.

### 5. Memory is what compounds.
The one people skip, and the only part that accrues value. A model has no memory of you. Give the system a place to read and write what it learns: a notes vault, a record of decisions. Feed the agents from it. Every session gets sharper because the substrate remembers even though the model does not.
*In this repo:* `memory/` (Step 4).

### 6. Config as code, or you don't own it.
If you can't roll it back, you're renting your setup from your own memory, and your memory isn't backed up. The OS config, the deployments, the whole layout should be declarative and reversible. A machine you can't rebuild from a repo is one bad night away from gone.
*In this repo:* everything is a file — compose, config, scripts, `.env.example`, `Makefile`.

### 7. Observe everything, because trust needs a chain.
You can't trust what you can't see. Telemetry isn't decoration on top; it's how you know the thing is behaving. Trace the agent calls. Log the model responses. A claim you can't trace is a claim you take on faith, and infrastructure run on faith fails silently.
*In this repo:* `optional/observability/` — added when there's something worth watching, not before.
