# Deploy Evolution API no Railway (automático)

Este guia usa o **repositório conectado ao GitHub** para deploy contínuo no Railway. O projeto já está configurado com `railway.json` e `Dockerfile`.

## Pré-requisitos

- Conta no [Railway](https://railway.app/) (login com GitHub)
- Repositório deste projeto no GitHub

---

## Deploy em 5 passos

### 1. Novo projeto no Railway

1. Acesse [railway.app](https://railway.app/) e faça login com GitHub.
2. Clique em **"New Project"**.
3. Escolha **"Deploy from GitHub repo"** e autorize o Railway no GitHub se pedir.
4. Selecione o repositório **evolution-api** (ou o nome do seu fork).

O Railway vai detectar o `railway.json` na raiz e usar o **Dockerfile** para build e deploy.

---

### 2. Adicionar PostgreSQL

1. No projeto, clique em **"+ New"** (ou **"Add Service"**).
2. Selecione **"Database"** → **"PostgreSQL"**.
3. Aguarde o Postgres subir. Anote o nome do serviço (ex.: `Postgres`).

---

### 3. Adicionar Redis (opcional, recomendado)

1. **"+ New"** → **"Database"** → **"Redis"**.
2. Aguarde subir. Anote o nome (ex.: `Redis`).

---

### 4. Variáveis de ambiente (Evolution API)

1. Clique no serviço **Evolution API** (o que veio do GitHub).
2. Abra a aba **"Variables"**.
3. Clique em **"Add Variable"** ou **"RAW Editor"** e configure:

| Variável | Valor | Observação |
|----------|--------|------------|
| `DATABASE_PROVIDER` | `postgresql` | Fixo |
| `DATABASE_CONNECTION_URI` | `${{Postgres.DATABASE_URL}}` | Referência ao Postgres (ajuste `Postgres` se o nome for outro) |
| `CACHE_REDIS_ENABLED` | `true` | Se tiver Redis |
| `CACHE_REDIS_URI` | `${{Redis.REDIS_URL}}` | Referência ao Redis (ajuste `Redis` se for outro) |
| `SERVER_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | URL pública (Railway preenche) |
| `AUTHENTICATION_API_KEY` | *(gere uma chave segura)* | Ex.: use um gerador de 32+ caracteres |

**Se não usar Redis:**  
Defina `CACHE_REDIS_ENABLED=false` e `CACHE_LOCAL_ENABLED=true`.

**Referências Railway:**  
- `${{Postgres.DATABASE_URL}}` = URL do banco (substitua `Postgres` pelo nome do seu serviço Postgres).  
- `${{Redis.REDIS_URL}}` = URL do Redis.  
- `${{RAILWAY_PUBLIC_DOMAIN}}` = domínio público do serviço (preenchido após gerar domínio).

4. Salve. O Railway faz redeploy quando variáveis mudam.

---

### 5. Volume para sessões WhatsApp (recomendado)

Para não perder as sessões (QR/autenticação) a cada redeploy:

1. No serviço **Evolution API**, aba **"Settings"**.
2. Em **"Volumes"**, clique em **"Add Volume"**.
3. **Mount Path:** `/evolution/instances`.
4. Salve e faça redeploy se necessário.

---

## Domínio público e healthcheck

1. No serviço **Evolution API**, aba **"Settings"** → **"Networking"** (ou **"Public Networking"**).
2. Clique em **"Generate Domain"**. O Railway vai criar um URL como `evolution-api-production-xxxx.up.railway.app`.
3. Use esse URL em `SERVER_URL`:  
   `SERVER_URL=https://evolution-api-production-xxxx.up.railway.app`  
   (ou use `https://${{RAILWAY_PUBLIC_DOMAIN}}` se já tiver domínio gerado).
4. **Healthcheck (opcional):** em **Settings** → **Deploy**, configure:
   - **Health Check Path:** `/health`  
   - **Health Check Timeout:** 30 s  

O endpoint `GET /health` retorna `{"status":"ok"}` e já existe na API.

---

## Testar o deploy

Após o deploy concluído:

```bash
# Health
curl https://SEU-DOMINIO.up.railway.app/health

# API (com apikey)
curl -H "apikey: SUA_AUTHENTICATION_API_KEY" https://SEU-DOMINIO.up.railway.app/instance/fetchInstances
```

---

## Deploy automático (CI)

- **Push no GitHub** na branch conectada ao Railway dispara **build e deploy automáticos**.
- O Railway usa o **Dockerfile** e o **railway.json** da raiz do repositório.
- Migrações do Prisma rodam no **entrypoint** do container (`deploy_database.sh` → `npm run db:deploy`).

---

## Resumo rápido

| Item | Ação |
|------|------|
| Código | Deploy from GitHub repo → selecionar este repositório |
| Build | Automático via `railway.json` + Dockerfile |
| Banco | Serviço PostgreSQL no Railway; `DATABASE_CONNECTION_URI=${{Postgres.DATABASE_URL}}` |
| Cache | Redis opcional; `CACHE_REDIS_URI=${{Redis.REDIS_URL}}` |
| Sessões | Volume em `/evolution/instances` |
| URL | Gerar domínio em Settings → Networking e usar em `SERVER_URL` |
| Healthcheck | Path: `/health` |

Com isso, o deploy no Railway fica automático a cada push no repositório.
