# Deploy Evolution API - GitHub + Hostinger Node.js

> **Para rodar localmente primeiro:** veja `PASSO_A_PASSO.md` (Docker ou Supabase).

## Pré-requisitos

1. **Banco de dados**
   - **Hostinger Node.js:** crie um banco MySQL no painel (MySQL Databases)
   - **Alternativa:** projeto Supabase (PostgreSQL gratuito) em https://supabase.com

2. **Variáveis no `.env`** (copie de `env.hostinger.example` ou `.env.example` se precisar)
   - `DATABASE_CONNECTION_URI` – string de conexão do banco
   - `AUTHENTICATION_API_KEY` – chave forte (ex.: `openssl rand -hex 32`)
   - `SERVER_URL` – URL final (ex.: `https://evolution.seudominio.com`)

---

## Publicar no GitHub

```bash
# Dentro da pasta evolution-api
git remote set-url origin https://github.com/SEU_USUARIO/evolution-api-lunins.git
git add .
git commit -m "Evolution API - config para Hostinger"
git push -u origin main
```

> O `.env` não é commitado (está no .gitignore). Configure as variáveis no painel Hostinger.

---

## Deploy Hostinger Node.js

1. Painel Hostinger → **Aplicações** → **Node.js** → **Conectar GitHub**
2. Selecione o repositório `evolution-api-lunins`
3. **Build:** `npm install && npm run db:generate && npm run build`
4. **Start:** `npm run start:prod`
5. **Porta:** 8080 (ou a indicada pela Hostinger)
6. **Variáveis de ambiente:** adicione todas as do `.env` no painel

### Migrations (antes do primeiro deploy)

Se tiver acesso SSH ou console da Hostinger:

```bash
npm run db:deploy
# ou no Windows: npm run db:deploy:win
```

Ou rode localmente apontando para o banco da Hostinger/Supabase e depois faça o deploy.

---

## Primeira configuração WhatsApp

1. Crie a instância:
```bash
curl -X POST https://sua-url/instance/create \
  -H "Content-Type: application/json" \
  -H "apikey: SUA_CHAVE" \
  -d '{"instanceName": "lunins"}'
```

2. Conecte e obtenha o QR Code:
```bash
curl https://sua-url/instance/connect/lunins -H "apikey: SUA_CHAVE"
```

3. Escaneie o QR Code no WhatsApp (Dispositivos vinculados)

---

## Integração com sistema Gestão (Lunins)

No `.env` do projeto gestao:

```
VITE_EVOLUTION_API_URL=https://sua-url-evolution.com
VITE_EVOLUTION_INSTANCE=lunins
VITE_EVOLUTION_API_KEY=SUA_CHAVE
```
