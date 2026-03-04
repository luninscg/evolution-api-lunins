# Evolution API – Passo a passo simples

## Opção A: Com Docker (mais fácil)

### 1. Abra o Docker Desktop e aguarde iniciar

### 2. No terminal, dentro da pasta `evolution-api`:

```powershell
docker compose up -d postgres redis
```

Aguarde ~30 segundos para o banco subir.

### 3. Crie as tabelas e inicie a API:

```powershell
npm run db:deploy:win
npm run start
```

### 4. Pronto!

- API em: **http://localhost:8080**
- Documentação: **http://localhost:8080/swagger**
- Chave de API: `lunins_evolution_2026_secure_key_xyz` (header `apikey`)

---

## Opção B: Sem Docker (usa Supabase)

### 1. Pegue a connection string do Supabase

- Acesse: https://supabase.com/dashboard/project/pitexeomwpgpmczujovr/settings/database  
- Em **Connection string** → **URI**, copie a string  
- Substitua `[YOUR-PASSWORD]` pela senha do banco (em **Database password**)

### 2. Configure o Supabase (escolha um):

**A) Script automático (mais fácil):**
```powershell
cd evolution-api
.\configurar-supabase.ps1
```
O script vai pedir a senha do banco e preencher o `.env` automaticamente.

**B) Manualmente:** abra `evolution-api\.env` e altere:
```
DATABASE_CONNECTION_URI='postgresql://postgres:SUA_SENHA@db.pitexeomwpgpmczujovr.supabase.co:5432/postgres'
CACHE_REDIS_ENABLED=false
CACHE_LOCAL_ENABLED=true
```

### 3. Crie as tabelas e inicie:

```powershell
cd evolution-api
npm run db:deploy:win
npm run start
```

### 4. Pronto!

- API em: **http://localhost:8080**
- Chave: `lunins_evolution_2026_secure_key_xyz`

---

## Depois: Conectar WhatsApp

1. **Criar instância:**
```powershell
curl -X POST http://localhost:8080/instance/create -H "Content-Type: application/json" -H "apikey: lunins_evolution_2026_secure_key_xyz" -d "{\"instanceName\": \"lunins\"}"
```

2. **Pegar QR Code:**
```powershell
curl http://localhost:8080/instance/connect/lunins -H "apikey: lunins_evolution_2026_secure_key_xyz"
```

3. Escaneie o QR Code no WhatsApp (Configurações > Dispositivos vinculados).

---

## Integrar com o sistema Gestão

No `.env` do projeto **gestao** (na raiz):

```
VITE_EVOLUTION_API_URL=http://localhost:8080
VITE_EVOLUTION_INSTANCE=lunins
VITE_EVOLUTION_API_KEY=lunins_evolution_2026_secure_key_xyz
```
