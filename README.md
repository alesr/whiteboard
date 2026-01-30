# Whiteboard

Self-hosted [Excalidraw](https://excalidraw.com/) with persistent storage, real-time collaboration, and Cloudflare Tunnel integration.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Cloudflare Tunnel                       │
│                    (draw.example.com)                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        Caddy (:8088)                        │
│                   (reverse proxy + auth)                    │
└─────────────────────────────────────────────────────────────┘
          │                   │                    │
          ▼                   ▼                    ▼
    ┌──────────┐       ┌──────────┐         ┌──────────┐
    │   App    │       │  Storage │         │   Room   │
    │ (:80)    │       │  (:8080) │         │  (:80)   │
    │ Excali-  │       │  Backend │         │ WebSocket│
    │ draw UI  │       │  API     │         │ Collab   │
    └──────────┘       └──────────┘         └──────────┘
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
- macos (Makefile uses `brew services`)

## Setup

### 1. Create `.env` file

```sh
cp .env.example .env
```

### 2. Generate a password hash

```sh
docker run --rm caddy:2 caddy hash-password --plaintext 'your_secret_password'
```

### 3. Edit `.env` with your values

```sh
# Required settings:
PUBLIC_URL=https://draw.yourdomain.com
EXCALIDRAW_USER=your_username
EXCALIDRAW_PASSWORD_BASE64=$$2a$$14$$your_hash_here  # Escape $ as $$
```

### 4. Configure Cloudflare Tunnel

Set up a tunnel named `excalidraw` pointing to `http://localhost:8088`.

### 5. Start

```sh
make start
```

## Commands

| Command | Description |
|---------|-------------|
| `make start` | Start everything (Docker + Tunnel) |
| `make stop` | Stop everything |
| `make restart` | Restart everything |
| `make status` | Show status of all services |
| `make logs` | Show Docker logs (follow mode) |
| `make test` | Test local and public connections |
| `make help` | Show all available commands |

### Docker-only

| Command | Description |
|---------|-------------|
| `make up` | Start Docker containers |
| `make down` | Stop Docker containers |
| `make clean` | Stop and remove all volumes (data loss!) |

### Tunnel-only

| Command | Description |
|---------|-------------|
| `make tunnel-start` | Start Cloudflare Tunnel |
| `make tunnel-stop` | Stop Cloudflare Tunnel |
| `make tunnel-manual` | Run tunnel manually (for debugging) |
| `make logs-tunnel` | Show tunnel logs |

## Services

| Service | Image | Purpose |
|---------|-------|---------|
| `app` | `alswl/excalidraw` | Excalidraw web UI |
| `room` | `excalidraw/excalidraw-room` | WebSocket server for real-time collaboration |
| `storage` | `alswl/excalidraw-storage-backend` | REST API for persisting scenes |
| `db` | `postgres:16` | PostgreSQL database |
| `caddy` | `caddy:2` | Reverse proxy with basic auth |

## Configuration

### Environment Variables

All configuration is done via the `.env` file. See `.env.example` for a documented template.

| Variable | Description | Default |
|----------|-------------|---------|
| `PUBLIC_URL` | Public URL where the app is accessible | `https://draw.example.com` |
| `LOCAL_PORT` | Local port for Docker to expose Caddy | `8088` |
| `EXCALIDRAW_USER` | Username for basic auth | `alesr` |
| `EXCALIDRAW_PASSWORD_BASE64` | Bcrypt hash of the password (escape `$` as `$$`) | (required) |
