ifneq (,$(wildcard ./.env))
    include .env
    export
endif

PUBLIC_URL ?= https://draw.example.com
LOCAL_PORT ?= 8088

.PHONY: start
start:
	@make up
	@make tunnel-start
	@echo "Access it at: $(PUBLIC_URL)"
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

.PHONY: tunnel-manual
tunnel-manual:
	cloudflared tunnel run excalidraw

.PHONY: status
status:
	@echo "Docker Containers:"
	docker compose ps
	@echo ""
	@echo "Cloudflare Tunnel:"
	ps aux | grep -v grep | grep cloudflared || echo "Tunnel not running"
	@echo ""
	@echo "Access URL: $(PUBLIC_URL)"

.PHONY: test
test:
	@echo "Testing connections..."
	@echo ""
	@echo "Local (http://localhost:$(LOCAL_PORT)):"
	curl -s -o /dev/null -w "%{http_code}\n" http://localhost:$(LOCAL_PORT) || echo "Failed"
	@echo ""
	@echo "Public ($(PUBLIC_URL)):"
	curl -s -o /dev/null -w "%{http_code}\n" $(PUBLIC_URL) || echo "Failed"

.PHONY: logs-tunnel
logs-tunnel:
	tail -50 ~/Library/Logs/cloudflared.out.log || echo "No output logs"
	@echo ""
	@echo "Error Logs:"
	tail -50 ~/Library/Logs/cloudflared.err.log || echo "No error logs"

# --- Service Management ---
.PHONY: tunnel-install
tunnel-install:
	brew services start cloudflared

.PHONY: tunnel-uninstall
tunnel-uninstall:
	brew services stop cloudflared

.PHONY: help
help:
	@echo "Excalidraw Management Commands:"
	@echo ""
	@echo "Core Commands:"
	@echo "  make start           - Start everything (Docker + Tunnel)"
	@echo "  make stop            - Stop everything (Tunnel + Docker)"
	@echo "  make restart         - Restart everything"
	@echo ""
	@echo "Docker Commands:"
	@echo "  make up              - Start Docker containers"
	@echo "  make down            - Stop Docker containers"
	@echo "  make logs            - Show Docker logs (follow mode)"
	@echo ""
	@echo "Cloudflare Tunnel Commands:"
	@echo "  make tunnel-start    - Start Cloudflare Tunnel"
	@echo "  make tunnel-stop     - Stop Cloudflare Tunnel"
	@echo "  make tunnel-restart  - Restart Cloudflare Tunnel"
	@echo "  make tunnel-manual   - Run Tunnel manually (for debugging)"
	@echo "  make tunnel-install  - Install Tunnel as a macOS service"
	@echo "  make tunnel-uninstall- Uninstall Tunnel service"
	@echo ""
	@echo "Status and Testing:"
	@echo "  make status          - Show status of all services"
	@echo "  make test            - Test local and public connections"
	@echo "  make logs-tunnel     - Show Cloudflare Tunnel logs"
	@echo "  make clean           - Stop and remove all volumes (data loss!)"
	@echo ""
	@echo "Public URL: $(PUBLIC_URL)"
