#!/bin/bash
# Fix Prisma JsonFilter path: 'x' -> path: ['x'] for PostgreSQL (run on VM if build still fails)
# Usage: from repo root: bash scripts/fix-prisma-path-vm.sh

set -e
cd "$(dirname "$0")/.."

echo ">>> Fixing path: '...' -> path: ['...'] in source files..."

for file in \
  src/api/integrations/channel/meta/whatsapp.business.service.ts \
  src/api/integrations/channel/whatsapp/whatsapp.baileys.service.ts \
  src/api/integrations/chatbot/chatwoot/services/chatwoot.service.ts \
  src/api/services/channel.service.ts; do
  [ -f "$file" ] || continue
  sed -i.bak \
    -e "s/path: 'id'/path: ['id']/g" \
    -e "s/path: 'fromMe'/path: ['fromMe']/g" \
    -e "s/path: 'participant'/path: ['participant']/g" \
    -e "s/path: 'remoteJid'/path: ['remoteJid']/g" \
    -e "s/path: 'remoteJidAlt'/path: ['remoteJidAlt']/g" \
    -e "s/path: 'participants'/path: ['participants']/g" \
    "$file"
  echo "  Fixed: $file"
done

echo ">>> Done. Run: npm run build && pm2 restart evolution-api"
