# Whiteboard

Self-hosted [Excalidraw](https://excalidraw.com/) and [Mermaid Live Editor](https://mermaid.live/) with persistent storage, real-time collaboration, and Cloudflare Tunnel integration.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Cloudflare Tunnel                       │
│         (draw.example.com / mermaid.example.com)            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        Caddy (:8088)                        │
│                   (reverse proxy + auth)                    │
└─────────────────────────────────────────────────────────────┘
     │              │                │                 │
     ▼              ▼                ▼                 ▼
┌─────────┐  ┌──────────┐     ┌──────────┐      ┌──────────┐
│ Mermaid │  │   App    │     │  Storage │      │   Room   │
│  (:80)  │  │  (:80)   │     │  (:8080) │      │  (:80)   │
│ Diagram │  │ Excali-  │     │  Backend │      │ WebSocket│
│ Editor  │  │ draw UI  │     │  API     │      │ Collab   │
└─────────┘  └──────────┘     └──────────┘      └──────────┘
                                    │
                                    ▼
                             ┌──────────┐
                             │ Postgres │
                             │  (:5432) │
                             └──────────┘
```

## Prerequisites

- Docker and Docker Compose
- [cloudflared](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/) (for tunnel)
- macOS (Makefile uses `brew services`)

## Setup

### 1. Create `.env` file

```sh
cp .env.example .env
```

### 2. Generate a password hash

```sh
docker run --rm caddy:2 caddy hash-password --plaintext 'foo'
```

### 3. Edit `.env` with your values

```sh
PUBLIC_URL=https://draw.yourdomain.com
MERMAID_PUBLIC_URL=https://mermaid.yourdomain.com
EXCALIDRAW_USER=username
EXCALIDRAW_PASSWORD_BASE64=$$2a$$14$$your_hash_here  # Escape $ as $$
```

### 4. Configure Cloudflare Tunnel

Set up a tunnel with two hostnames:
- `draw.yourdomain.com` → `http://localhost:8088`
- `mermaid.yourdomain.com` → `http://localhost:8088`

Example `~/.cloudflared/config.yml`:

```yaml
tunnel: your-tunnel-id
credentials-file: /path/to/credentials.json

ingress:
  - hostname: draw.yourdomain.com
    service: http://localhost:8088
  - hostname: mermaid.yourdomain.com
    service: http://localhost:8088
  - service: http_status:404
```

### 5. Start

```sh
make start
```
