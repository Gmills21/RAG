# Pilot Deployment Guide

This guide covers three paths:

- Personal/local testing before customer infrastructure.
- The default paid-pilot path: a dedicated single-customer deployment with fast hosted inference.
- The private-GPU exception when a customer forbids hosted inference.

Do not build or operate a multi-tenant SaaS deployment for v0.

## Clean Deployment Vision

| Use case | App hosting | Inference | Why |
|---|---|---|---|
| Personal testing | Laptop Docker | `dev-ollama` on laptop | Free/private rehearsal; no speed promise |
| Prospect demo | Local or demo host | `demo-hosted` | Fast enough to sell the experience |
| Paid pilot | Dedicated single-customer VPS | `pilot-hosted` | Default production-speed path |
| Restricted customer | Dedicated GPU VPS | `pilot-private-gpu` | Only when hosted inference is not allowed |

Ollama on a laptop is for testing the workflow. It is not the production-speed
story. Paid pilots should use `pilot-hosted` unless the customer explicitly
requires private inference.

## Local Testing Path

Use local testing for internal validation, sample-data demos, and source-quality
reviews before any VPS work.

```bash
./scripts/setup_ollama.sh
./scripts/preflight.sh
docker compose up -d
```

Open:

```text
http://localhost:7860
```

Configure Kotaemon with `config/inference/dev-ollama.example.yml`. Local testing
should work before any VPS, VPN, customer server, domain, or reverse proxy setup.
Upload only fake demo docs or customer-approved pilot docs.

## Default Pilot Path: Dedicated VPS Plus Hosted Inference

Use one VPS per customer for first pilots. This isolates app state and customer
docs while using a faster hosted inference endpoint for production behavior.

Required assumptions:

- Docker and Docker Compose are installed on the VPS.
- A customer-specific domain or subdomain points to the VPS.
- HTTPS is provided by Caddy or another reverse proxy.
- Basic auth or stronger access control is enabled before users are invited.
- Encrypted disk is enabled where available.
- Firewall rules expose only SSH plus HTTP/HTTPS.
- `OPENAI_API_KEY`, Azure OpenAI credentials, or a customer-approved hosted endpoint is available.

The VPS runs Kotaemon and the reverse proxy. The LLM and embedding calls use
`config/inference/pilot-hosted.example.yml` by default.

## Non-Negotiable Deployment Rules

- Do not expose raw Kotaemon port 7860 publicly.
- Use one customer per VPS for first pilots.
- Use customer-specific `ktem_app_data` and `customer_docs` folders.
- Copy only approved prepared docs to the pilot host.
- Keep demo data and customer data separate.
- Enable access control before sending a customer URL.
- Do not add broad workspace integrations in v0.
- Do not use laptop Ollama as the paid-pilot speed story.

The base `docker-compose.yml` binds Kotaemon to localhost. Public access should
go through the reverse proxy in `docker-compose.pilot.yml`, not directly to port
7860.

## Folder Layout

Recommended customer-specific layout on the VPS:

```text
/opt/support-kb-pilots/
  customer_acme/
    repo/
    customer_docs/
    prepared_docs/
    pilot_records/
    backups/
```

Inside the repo, Kotaemon state lives in:

```text
./ktem_app_data
```

Do not reuse this app data folder for another customer.

## Configure The Default Pilot

1. Provision a dedicated VPS.
2. Install Docker and Docker Compose.
3. Clone or copy this repository to the customer-specific folder.
4. Copy the pilot env example:

```bash
cp .env.pilot.example .env
```

5. Set `PUBLIC_HOST` to the customer-specific domain.
6. Generate a strong basic-auth hash and set `BASIC_AUTH_HASH`.
7. Set `OPENAI_API_KEY` or the customer-approved hosted endpoint credentials.
8. Copy the Caddy example and review it:

```bash
cp Caddyfile.example Caddyfile
```

9. Validate the composed config:

```bash
docker compose -f docker-compose.yml -f docker-compose.pilot.yml config
```

10. Start the pilot:

```bash
docker compose -f docker-compose.yml -f docker-compose.pilot.yml up -d
```

11. Confirm HTTPS and basic auth work:

```text
https://your-customer-host.example.com
```

12. In Kotaemon, configure resources with `config/inference/pilot-hosted.example.yml`.
13. Upload only approved prepared customer docs.
14. Run the customer's known questions and record latency/quality notes.

## Kotaemon Model Configuration For Default Pilots

Use `pilot-hosted` unless the customer requires a different approved endpoint.

LLM:

```yaml
vendor: ChatOpenAI
api_key: ${OPENAI_API_KEY}
base_url: https://api.openai.com/v1/
model: gpt-4o-mini
```

Embeddings:

```yaml
vendor: ChatOpenAI
api_key: ${OPENAI_API_KEY}
base_url: https://api.openai.com/v1/
model: text-embedding-3-small
```

If the customer uses Azure OpenAI or another approved OpenAI-compatible endpoint,
replace the base URL and model names with the approved values. Re-index after
changing the embedding model.

## Private-GPU Exception

Use `pilot-private-gpu` only when hosted inference is forbidden.

Requirements:

- A GPU VPS or customer-owned GPU host is available.
- The model server exposes an OpenAI-compatible API.
- The path passes the same speed expectation as hosted pilots.
- The customer understands model quality may differ from the hosted default.

If the model server runs on the VPS host and Kotaemon runs in Docker, use:

```text
http://host.docker.internal:11434/v1/
```

If the model server runs as another Docker service, use that service URL. Do not
use `127.0.0.1` from inside the Kotaemon container unless the model server is in
the same container.

## Move From Local Validation To VPS Pilot

Move only these approved items:

- Prepared customer docs from `prepared_docs/`.
- The selected prompt pack, usually `prompt-packs/support_v1.md`.
- The known-question eval list or customer-specific eval sheet.
- Any written setup notes needed to reproduce the pilot configuration.

Do not copy:

- Full workspace exports.
- Slack DMs or private channels.
- Raw ticket dumps that were not approved.
- Another customer's `ktem_app_data`.
- Local `.env` files from unrelated deployments.

## Verification Checklist

- [ ] Local testing passed before VPS setup.
- [ ] DNS points to the VPS.
- [ ] HTTPS loads through the reverse proxy.
- [ ] Basic auth or stronger access control blocks unauthenticated access.
- [ ] Raw `7860` is not publicly reachable.
- [ ] Kotaemon is configured with `pilot-hosted` or an approved equivalent.
- [ ] Embeddings were re-indexed after profile changes.
- [ ] Only approved prepared docs are uploaded.
- [ ] Cited answers work for the known questions.
- [ ] Standard questions meet the production-speed target or the issue is documented before launch.

## Reset Or Stop A Pilot

To stop services:

```bash
docker compose -f docker-compose.yml -f docker-compose.pilot.yml down
```

To reset app data after customer approval:

```bash
./scripts/reset_local_data.sh --yes
```

Keep deletion requests and completion notes in the customer pilot record.
