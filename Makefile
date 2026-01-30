ifneq (,$(wildcard ./.env))
    include .env
    export
endif

PUBLIC_URL ?= https://draw.example.com
MERMAID_PUBLIC_URL ?= https://mermaid.example.com
EXCALIDRAW_DOMAIN ?= draw.localhost
MERMAID_DOMAIN ?= mermaid.localhost
LOCAL_PORT ?= 8088

.PHONY: start
start:
	@make up
	@make tunnel-start
	@echo "Excalidraw: $(PUBLIC_URL)"
	@echo "Mermaid:    $(MERMAID_PUBLIC_URL)"
	@echo ""
	@make status

.PHONY: stop
stop:
	@make tunnel-stop
	@make down

.PHONY: restart
restart:
	@make stop
	@make start

.PHONY: up
up:
	docker compose up -d

.PHONY: down
down:
	docker compose down

.PHONY: clean
clean:
	docker compose down -v

.PHONY: logs
logs:
	docker compose logs -f

.PHONY: tunnel-start
tunnel-start:
	brew services start cloudflared
	@sleep 2

.PHONY: tunnel-stop
tunnel-stop:
	brew services stop cloudflared

.PHONY: tunnel-restart
tunnel-restart:
	@make tunnel-stop
	@make tunnel-start

.PHONY: status
status:
	@echo "Docker Containers:"
	docker compose ps
	@echo ""
	@echo "Cloudflare Tunnel:"
	ps aux | grep -v grep | grep cloudflared || echo "Tunnel not running"
	@echo ""
	@echo "Access URLs:"
	@echo "  Excalidraw: $(PUBLIC_URL)"
	@echo "  Mermaid:    $(MERMAID_PUBLIC_URL)"

.PHONY: logs-tunnel
logs-tunnel:
	tail -50 ~/Library/Logs/cloudflared.out.log || echo "No output logs"
	@echo ""
	@echo "Error Logs:"
	tail -50 ~/Library/Logs/cloudflared.err.log || echo "No error logs"

.PHONY: tunnel-install
tunnel-install:
	brew services start cloudflared
