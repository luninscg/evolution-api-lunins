#!/bin/bash
# Run this ONCE after SSH into the VM. Clones repo, creates .env with auto-detected
# SERVER_URL and generated API key, installs Postgres, builds and starts with PM2.
#
# One-liner (paste in SSH session):
#   git clone https://github.com/luninscg/evolution-api-lunins.git evolution-api && cd evolution-api && bash scripts/ssh-bootstrap.sh

set -e

REPO_URL="${REPO_URL:-https://github.com/luninscg/evolution-api-lunins.git}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/evolution-api}"

echo "=== Evolution API - SSH Bootstrap (full auto) ==="
echo ""

# Must be run from repo root (after clone) or we clone here
if [ -d ".git" ]; then
  INSTALL_DIR="$(pwd)"
  echo ">>> Using current directory as repo: $INSTALL_DIR"
else
  echo ">>> Cloning repository..."
  git clone "$REPO_URL" "$INSTALL_DIR"
  cd "$INSTALL_DIR"
fi

cd "$INSTALL_DIR"

# Create .env from example if missing
if [ ! -f .env ]; then
  [ -f .env.example ] || { echo "No .env.example found."; exit 1; }
  cp .env.example .env
  echo ">>> Created .env from .env.example"
fi

# Detect public IP for SERVER_URL (skip if already set to something other than localhost)
if ! grep -q "^SERVER_URL=http://[0-9]" .env 2>/dev/null; then
  PUBLIC_IP=$(curl -s --max-time 5 https://ifconfig.me 2>/dev/null || curl -s --max-time 5 https://api.ipify.org 2>/dev/null || echo "SEU_IP")
  SERVER_URL="http://${PUBLIC_IP}:8080"
  sed -i.bak "s|^SERVER_URL=.*|SERVER_URL=$SERVER_URL|" .env 2>/dev/null || true
  echo ">>> Set SERVER_URL=$SERVER_URL"
fi

# Generate and set AUTHENTICATION_API_KEY
API_KEY="EvoApi$(openssl rand -hex 16)"
sed -i.bak "s|^AUTHENTICATION_API_KEY=.*|AUTHENTICATION_API_KEY=$API_KEY|" .env 2>/dev/null || true
echo ">>> Set AUTHENTICATION_API_KEY (save it): $API_KEY"

# Cache local (no Redis)
sed -i.bak 's/^CACHE_REDIS_ENABLED=.*/CACHE_REDIS_ENABLED=false/' .env 2>/dev/null || true
sed -i.bak 's/^CACHE_LOCAL_ENABLED=.*/CACHE_LOCAL_ENABLED=true/' .env 2>/dev/null || true

# Run full setup with auto Postgres
export AUTO_INSTALL_DATABASE=postgresql
bash "$(dirname "$0")/setup-gcp-vm.sh"

echo ""
echo ">>> Done. Save your AUTHENTICATION_API_KEY from above. Test: curl -H 'apikey: SUA_CHAVE' http://$(curl -s ifconfig.me 2>/dev/null || echo 'IP'):8080/health"
