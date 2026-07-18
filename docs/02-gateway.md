# Step 2 — Put a gateway in front of the models

**Goal:** one endpoint on your tailnet that speaks the OpenAI API and fans out to every model provider behind it. After this, choosing a model is a line of config, not a code change.

> Principle: *Rent the mind. Own the house.* Everything that calls a model calls the gateway. The day the best model changes, you change a route and nothing downstream notices. See `PRINCIPLES.md`.

We use **LiteLLM** as the gateway, in Docker.

---

## 2.1 Install Docker

On the box:

```
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER && newgrp docker
```

- Install Docker Engine on Ubuntu (manual, recommended for production): https://docs.docker.com/engine/install/ubuntu/
- Run Docker as a non-root user: https://docs.docker.com/engine/install/linux-postinstall/

## 2.2 Get your provider API keys

You need at least one. Start with two or three. Put them in `.env` (copy from `.env.example`) — **never commit `.env`**.

- **Anthropic** (Claude): https://console.anthropic.com/ → API keys
- **Groq** (fast, cheap inference): https://console.groq.com/keys
- **OpenAI** (GPT): https://platform.openai.com/api-keys

Full provider list LiteLLM supports: https://docs.litellm.ai/docs/providers

## 2.3 Configure the gateway

The config lives in `gateway/litellm.config.yaml`. It maps friendly model names to `provider/model` targets and pulls keys from the environment. It already has Anthropic, Groq, and OpenAI entries — trim to what you have.

```yaml
model_list:
  - model_name: claude
    litellm_params:
      model: anthropic/claude-sonnet-5
      api_key: os.environ/ANTHROPIC_API_KEY
  - model_name: fast
    litellm_params:
      model: groq/openai/gpt-oss-20b
      api_key: os.environ/GROQ_API_KEY
  - model_name: gpt
    litellm_params:
      model: openai/gpt-5.6
      api_key: os.environ/OPENAI_API_KEY
```

- Config reference: https://docs.litellm.ai/docs/proxy/configs
- Proxy quick start: https://docs.litellm.ai/docs/proxy/quick_start

## 2.4 Run it — bound to the tailnet, not the world

`gateway/docker-compose.yml` binds the proxy to your Tailscale IP on port 4000. **Set `TAILSCALE_IP` and `LITELLM_MASTER_KEY` in `.env` first.** Then:

```
cd gateway
docker compose up -d
```

The compose file publishes the port as `${TAILSCALE_IP}:4000:4000` — never `0.0.0.0` (see the Docker gotcha in Step 1). `LITELLM_MASTER_KEY` is the key your tools present to the gateway; make it long and random.

- Docker quick start for LiteLLM: https://docs.litellm.ai/docs/proxy/docker_quick_start

---

## ✅ Verification (must pass before Step 3)

From the box or your laptop (on the tailnet), list the models the gateway is serving:

```
curl http://<TAILSCALE_IP>:4000/v1/models \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY"
```

You should get JSON listing `claude`, `fast`, `gpt` (whatever you configured). A quick chat round-trip:

```
curl http://<TAILSCALE_IP>:4000/v1/chat/completions \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"claude","messages":[{"role":"user","content":"say hello"}]}'
```

A real reply means the gateway is live and your keys work. From a machine **not** on the tailnet, the same curl should hang or refuse — that's the point. This was the single most valuable hour of the build: model choice is now a setting.
