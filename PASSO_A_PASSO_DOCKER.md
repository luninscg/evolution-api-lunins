# Evolution API – Passo a passo com Docker

## Pré-requisito
- Docker Desktop instalado e **aberto** (status: Engine running)

---

## Passo 1: Abrir o terminal

No Cursor: pressione **Ctrl+`** (ou menu Terminal → New Terminal)

---

## Passo 2: Ir para a pasta do Evolution

```powershell
cd c:\Users\Usuário\Desktop\gestao\evolution-api
```

---

## Passo 3: Subir PostgreSQL e Redis

```powershell
docker compose up -d postgres redis
```

**Aguarde ~30 segundos.** No Docker Desktop, em **Containers**, devem aparecer:
- `evolution_postgres`
- `evolution_redis`

---

## Passo 4: Criar as tabelas no banco

```powershell
npm run db:deploy:win
```

Deve rodar sem erros.

---

## Passo 5: Iniciar a Evolution API

```powershell
npm run start
```

A API sobe em **http://localhost:8080**.

---

## Passo 6: Conectar o WhatsApp

**6.1** Em **outro** terminal (Ctrl+Shift+`), criar a instância:

```powershell
curl -X POST http://localhost:8080/instance/create -H "Content-Type: application/json" -H "apikey: lunins_evolution_2026_secure_key_xyz" -d "{\"instanceName\": \"lunins\"}"
```

**6.2** Obter o QR Code:

```powershell
curl http://localhost:8080/instance/connect/lunins -H "apikey: lunins_evolution_2026_secure_key_xyz"
```

**6.3** No celular: WhatsApp → Configurações → Dispositivos vinculados → Vincular dispositivo → escanear o QR Code.

---

## Passo 7: Integrar com o sistema Gestão

No `.env` do projeto **gestao** (na raiz do projeto), inclua:

```
VITE_EVOLUTION_API_URL=http://localhost:8080
VITE_EVOLUTION_INSTANCE=lunins
VITE_EVOLUTION_API_KEY=lunins_evolution_2026_secure_key_xyz
```

---

## Resumo rápido

| Passo | Comando |
|-------|---------|
| 1 | Abrir terminal |
| 2 | `cd c:\Users\Usuário\Desktop\gestao\evolution-api` |
| 3 | `docker compose up -d postgres redis` |
| 4 | `npm run db:deploy:win` |
| 5 | `npm run start` |
| 6 | Criar instância e escanear QR Code |
| 7 | Configurar .env do gestao |

---

## Problemas comuns

**"Cannot connect to the Docker daemon"**  
→ Abra o Docker Desktop e aguarde até aparecer "Engine running".

**Erro no Passo 3**  
→ Verifique se as portas 5432 e 6379 não estão em uso por outros programas.

**Parar os containers**  
```powershell
docker compose down
```
