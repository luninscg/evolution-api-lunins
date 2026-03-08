#!/bin/bash
# Setup Evolution API on Ubuntu 22.04 (GCP VM or any Linux)
# Run: bash scripts/setup-gcp-vm.sh
# Or after clone: cd evolution-api && bash scripts/setup-gcp-vm.sh

set -e

REPO_URL="${REPO_URL:-https://github.com/luninscg/evolution-api-lunins.git}"
# If run from inside the repo, use current dir; otherwise clone to INSTALL_DIR
if [ -d ".git" ]; then
  INSTALL_DIR="$(pwd)"
else
  INSTALL_DIR="${INSTALL_DIR:-$HOME/evolution-api}"
fi

echo "=== Evolution API - Setup GCP VM ==="
echo "Repository: $REPO_URL"
echo "Install dir: $INSTALL_DIR"
echo ""

# 1. Install Node.js 20 if not present
if ! command -v node &>/dev/null; then
  echo ">>> Installing Node.js 20..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi
node -v
npm -v

# 2. Install Git and build-essential if not present
if ! command -v git &>/dev/null; then
  echo ">>> Installing Git and build-essential..."
  sudo apt-get update
  sudo apt-get install -y git build-essential
fi

# 3. Install PM2 globally if not present
if ! command -v pm2 &>/dev/null; then
  echo ">>> Installing PM2..."
  sudo npm install -g pm2
fi

# 4. Clone or update repo
if [ -d "$INSTALL_DIR/.git" ]; then
  echo ">>> Updating existing repo..."
  cd "$INSTALL_DIR"
  git pull
else
  echo ">>> Cloning repository..."
  if [ -d "$INSTALL_DIR" ]; then
    echo "Directory $INSTALL_DIR exists but is not a git repo. Remove it or set INSTALL_DIR."
    exit 1
  fi
  git clone "$REPO_URL" "$INSTALL_DIR"
  cd "$INSTALL_DIR"
fi

# 5. Create .env if missing; optionally install database on this VM
if [ ! -f .env ]; then
  if [ -f .env.example ]; then
    cp .env.example .env
  else
    echo ">>> No .env or .env.example found. Create .env with required variables."
    exit 1
  fi
fi

# 5b. Optional: install PostgreSQL or MySQL on this VM and set DATABASE_* in .env
if [ -n "$AUTO_INSTALL_DATABASE" ]; then
  echo ">>> Auto-installing database: $AUTO_INSTALL_DATABASE"
  bash "$(dirname "$0")/setup-database-gcp-vm.sh" "$AUTO_INSTALL_DATABASE"
fi

if ! grep -q "DATABASE_CONNECTION_URI=.*@" .env 2>/dev/null; then
  echo ">>> .env has no DATABASE_CONNECTION_URI set. Edit .env (SERVER_URL, AUTHENTICATION_API_KEY, DATABASE_*) or run with AUTO_INSTALL_DATABASE=postgresql"
  echo ">>> Example: AUTO_INSTALL_DATABASE=postgresql bash scripts/setup-gcp-vm.sh"
  exit 1
fi

# 6. Install deps, generate Prisma, build, deploy migrations
echo ">>> Installing dependencies..."
npm ci

# DATABASE_PROVIDER from .env or default postgresql
export $(grep -v '^#' .env | xargs) 2>/dev/null || true
DB_PROVIDER="${DATABASE_PROVIDER:-postgresql}"
export DATABASE_PROVIDER="$DB_PROVIDER"
echo ">>> Using DATABASE_PROVIDER=$DATABASE_PROVIDER"

echo ">>> Generating Prisma client..."
npm run db:generate

echo ">>> Building..."
npm run build

echo ">>> Deploying database migrations..."
npm run db:deploy

# 7. PM2 start or restart
echo ">>> Starting with PM2..."
pm2 delete evolution-api 2>/dev/null || true
pm2 start dist/main.js --name evolution-api
pm2 save
echo ""
echo ">>> PM2 startup (run on boot) - run the command that pm2 suggests:"
pm2 startup || true
echo ""
echo "=== Done. API should be listening on port 8080. ==="
echo "Test: curl http://$(curl -s ifconfig.me 2>/dev/null || echo 'IP_DA_VM'):8080/health"
echo "Logs: pm2 logs evolution-api"
