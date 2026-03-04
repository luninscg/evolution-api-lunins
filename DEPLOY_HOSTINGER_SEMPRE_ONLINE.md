# Evolution API – Deploy na Hostinger (sempre online)

Guia para manter o Evolution API rodando 24/7 no plano Business da Hostinger com Node.js.

---

## O que o plano Business oferece

- **5 aplicações Node.js** gerenciadas
- **2 CPU, 3 GB RAM** por app
- **Deploy via GitHub** (deploy automático)
- **Sempre online** – a plataforma mantém o app rodando e reinicia em caso de queda
- **MySQL** incluso (Databases)
- **SSL gratuito** e CDN

---

## Visão geral

| Componente    | Solução Hostinger                    |
|---------------|--------------------------------------|
| Node.js       | App gerenciada (sempre online)       |
| Banco de dados| MySQL (Databases no hPanel)          |
| Cache         | Local (sem Redis no plano compartilhado) |
| WhatsApp      | Evolution API com instância "lunins" |

---

## Passo 1: Criar banco MySQL na Hostinger

1. Acesse o **hPanel** da Hostinger
2. Vá em **Sites** → **Gerenciar** (ou Manage)
3. Na barra lateral esquerda, clique em **Gerenciamento**
4. Na seção **"Criar uma Nova Base de Dados MySQL e Base de Dados de Usuário"** (ou similar), defina:
   - **Nome do banco:** `evolution_db` (a Hostinger adiciona um prefixo tipo `u123456_`)
   - **Nome do usuário:** `evolution_user`
   - **Senha:** forte (8+ caracteres, maiúscula, minúscula, número)

5. Clique em **Criar**. A Hostinger mostra o nome completo (ex: `u766681042_evolution_db`). Use na connection string:
   ```
   mysql://u766681042_evolution_user:SENHA@localhost:3306/u766681042_evolution_db
   ```
   *Substitua o prefixo `u766681042` pelo seu. Senha com `@` ou `#` → use `%40` ou `%23`.*

---

## Passo 2: Publicar no GitHub

1. Crie um repositório no GitHub (ex: `evolution-api-lunins`)

2. No terminal local:
   ```powershell
   cd c:\Users\Usuário\Desktop\gestao\evolution-api
   git remote set-url origin https://github.com/SEU_USUARIO/evolution-api-lunins.git
   git add .
   git commit -m "chore: config para deploy Hostinger" --no-verify
   git push -u origin main
   ```

---

## Passo 3: Criar app Node.js na Hostinger

1. No **hPanel** → **Aplicações** → **Node.js**
2. Clique em **Adicionar aplicação** ou **Create application**
3. **Conectar ao GitHub:**
   - Autorize a Hostinger no GitHub
   - Selecione o repositório `evolution-api-lunins`
   - Branch: `main`

4. **Configurar build e start:**

   | Campo        | Valor |
   |--------------|-------|
   | **Build command** | `npm install && npm run db:generate && npm run build` |
   | **Start command** | `npm run start:prod` |
   | **Root directory** | `/` (raiz) |
   | **Node.js version** | 20.x |
   | **Porta** | 8080 (ou a que a Hostinger indicar) |

---

## Passo 4: Variáveis de ambiente

No painel da aplicação Node.js, em **Environment Variables** ou **Variáveis**, adicione:

| Variável | Valor |
|----------|-------|
| `DATABASE_PROVIDER` | `mysql` |
| `DATABASE_CONNECTION_URI` | `mysql://evolution_user:SENHA@localhost:3306/evolution_db` |
| `CACHE_REDIS_ENABLED` | `false` |
| `CACHE_LOCAL_ENABLED` | `true` |
| `AUTHENTICATION_API_KEY` | uma chave forte (ex: gere com `openssl rand -hex 32`) |
| `SERVER_URL` | `https://evolution.seudominio.com` (ou a URL que a Hostinger gerar) |
| `SERVER_PORT` | `8080` |

Substitua `SENHA` pela senha real do MySQL (com caracteres especiais em URL encoding).

---

## Passo 5: Migrations (tabelas no banco)

As migrations devem rodar no ambiente de produção. Duas opções:

**Opção A – Build script**

Altere o build para (no painel Hostinger):

```
npm install && npm run db:generate && npm run db:deploy && npm run build
```

Assim as migrations rodam durante o deploy. *Requer que as variáveis de ambiente (incluindo `DATABASE_CONNECTION_URI`) estejam configuradas antes do build.*

**Opção B – SSH**

1. Se tiver acesso SSH: conecte e vá até a pasta da aplicação
2. Rode: `npm run db:deploy`

**Opção C – Rodar localmente antes do deploy**

1. Configure temporariamente o `.env` local com a connection string do MySQL da Hostinger
2. Execute: `npm run db:deploy:win`
3. Faça o deploy normal

---

## Passo 6: Deploy e teste

1. Clique em **Deploy** ou **Redeploy**
2. Acompanhe o log do build
3. Quando concluir, a app estará em algo como `https://evolution-xxx.hostinger.com` ou no subdomínio que configurou

---

## Passo 7: Conectar WhatsApp

Com a API online, crie e conecte a instância:

```powershell
curl -X POST https://SUA-URL-HOSTINGER/instance/create -H "Content-Type: application/json" -H "apikey: SUA_CHAVE" -d "{\"instanceName\": \"lunins\"}"
curl https://SUA-URL-HOSTINGER/instance/connect/lunins -H "apikey: SUA_CHAVE"
```

Escanear o QR Code no WhatsApp (Configurações → Dispositivos vinculados).

---

## Passo 8: Integrar com o sistema Gestão

No `.env` do projeto **gestao**:

```
VITE_EVOLUTION_API_URL=https://evolution.seudominio.com
VITE_EVOLUTION_INSTANCE=lunins
VITE_EVOLUTION_API_KEY=SuaChaveAqui
```

---

## Garantir que fique sempre online

- A plataforma Node.js da Hostinger **reinicia** o app em caso de erro
- Ela também faz **health checks**
- Se usar **VPS** da Hostinger, configure **PM2** para maior controle:
  ```bash
  npm install -g pm2
  pm2 start dist/main.js --name evolution-api
  pm2 save
  pm2 startup
  ```

---

## Checklist rápido

- [ ] MySQL criado na Hostinger
- [ ] Código no GitHub
- [ ] App Node.js criada e ligada ao repositório
- [ ] Variáveis de ambiente configuradas
- [ ] Migrations executadas
- [ ] Deploy feito com sucesso
- [ ] Instância WhatsApp criada e conectada
- [ ] Sistema Gestão apontando para a URL da Evolution
