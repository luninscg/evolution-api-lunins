# Guia: Evolution API no Hostinger Business (Node.js)

Este guia explica como instalar e deixar a **Evolution API** online no **Node.js do Hostinger Business**.

---

## Requisitos

- Conta **Hostinger Business** (ou Cloud com suporte a Node.js)
- **MySQL** criado no hPanel (o plano Business inclui banco MySQL)
- Repositório da Evolution API no **GitHub** ou arquivos em **ZIP**
- Node.js **20.x** ou **22.x** (configurável no painel)

---

## Passo 1: Banco de dados MySQL no Hostinger

1. Acesse o **hPanel** da Hostinger.
2. Vá em **Bancos de dados** → **Bancos de dados MySQL**.
3. Crie um novo banco de dados e anote:
   - **Nome do banco**
   - **Usuário**
   - **Senha**
   - **Host** (geralmente `localhost`)

A connection string será no formato:

```text
mysql://USUARIO:SENHA@localhost:3306/NOME_DO_BANCO
```

Substitua `USUARIO`, `SENHA` e `NOME_DO_BANCO` pelos dados reais.  
Se a Hostinger informar um host diferente (ex.: `mysql.hostinger.com`), use esse host no lugar de `localhost`.

---

## Passo 2: Deploy da aplicação no Hostinger

### Opção A: Deploy pelo GitHub (recomendado)

1. No hPanel, acesse **Node.js** (ou **Aplicações** → **Node.js**).
2. Clique em **Adicionar aplicação** ou **Criar aplicação**.
3. Conecte sua conta **GitHub** e selecione o repositório da Evolution API.
4. Escolha o **branch** (geralmente `main` ou `master`).
5. Defina:
   - **Node.js**: 20.x ou 22.x.
   - **Comando de build**:  
     `npm install && npm run build`
   - **Comando de start**:  
     `npm run start:prod`
   - **Diretório raiz**: deixe em branco se o projeto estiver na raiz do repositório.

Se o Hostinger pedir apenas um “start command”, use:  
`npm run start:prod`  
(e faça o build antes, se houver etapa de build separada).

### Opção B: Deploy por upload (ZIP)

1. No seu PC, na pasta do projeto Evolution API:
   - Gere o build: `npm run build`.
   - Crie um ZIP contendo:
     - pasta `dist/`
     - `package.json`
     - `package-lock.json` (ou `yarn.lock`)
     - pasta `prisma/`
     - arquivo `.env` (você vai configurar no próximo passo; pode criar um vazio e preencher no painel).
2. No hPanel, em **Node.js**, crie uma nova aplicação e faça upload desse ZIP.
3. Configure o **comando de start**: `node dist/main.js` ou `npm run start:prod` (se no ZIP tiver `package.json` com esse script).

---

## Passo 3: Variáveis de ambiente no Hostinger

No painel da aplicação Node.js, abra **Variáveis de ambiente** (ou **Environment variables**) e configure no mínimo:

| Variável | Valor | Obrigatório |
|----------|--------|-------------|
| `DATABASE_PROVIDER` | `mysql` | Sim |
| `DATABASE_CONNECTION_URI` | `mysql://USUARIO:SENHA@localhost:3306/NOME_DO_BANCO` | Sim |
| `AUTHENTICATION_API_KEY` | Uma chave forte (ex.: gerada em [uuidgenerator.net](https://www.uuidgenerator.net/)) | Sim |
| `SERVER_PORT` | Porta que o Hostinger atribui à app (ex.: `8080` ou a variável `PORT` que eles informarem) | Sim |
| `SERVER_URL` | URL pública da sua API (ex.: `https://sua-api.seudominio.com`) | Recomendado |
| `CACHE_REDIS_ENABLED` | `false` | Se não tiver Redis |
| `CACHE_LOCAL_ENABLED` | `true` | Quando Redis estiver desabilitado |

**Exemplo de `DATABASE_CONNECTION_URI`:**

```text
mysql://u123456789_evolution:SenhaForte123@localhost:3306/u123456789_evolution
```

**Exemplo de `SERVER_URL`:**

```text
https://evolution.seudominio.com
```

Se o Hostinger injetar a porta em `PORT`, defina também:

```text
SERVER_PORT=<valor que a Hostinger mostrar para PORT>
```

Assim a Evolution API sobe na porta correta.

---

## Passo 4: Migrations do banco (MySQL)

A Evolution API usa **Prisma** e precisa rodar as migrations no MySQL.

- **Se você tem acesso SSH ao Hostinger** (VPS ou plano que permita):
  1. Conecte por SSH na pasta da aplicação.
  2. Defina: `export DATABASE_PROVIDER=mysql`
  3. Gere o client: `npm run db:generate`
  4. Rode as migrations:  
     - Linux/Mac: `npm run db:deploy`  
     - Windows (no Hostinger é raro): `npm run db:deploy:win`

- **Se não tiver SSH** (apenas Node.js no shared/cloud):
  - Alguns planos permitem um “script de build” ou “comando pós-instalação”. Se puder rodar comandos, use nessa etapa:
    - `npm run db:generate`
    - `npm run db:deploy`
  - Caso contrário, você pode rodar as migrations **localmente** apontando para o MySQL remoto da Hostinger:
    1. No hPanel, em MySQL, verifique se há “Acesso remoto” e libere seu IP.
    2. No seu PC, na pasta do projeto, crie um `.env` com `DATABASE_PROVIDER=mysql` e `DATABASE_CONNECTION_URI` com o host remoto (ex.: `mysql.hostinger.com`).
    3. Rode: `npm run db:generate` e depois `npm run db:deploy`.

Assim as tabelas são criadas no banco que a Evolution usará no Hostinger.

---

## Passo 5: Porta e URL da aplicação

- A Evolution lê a porta de `SERVER_PORT` (código em `src/config/env.config.ts`).
- No Hostinger, use o mesmo valor que eles usam para a aplicação (muitas vezes a variável `PORT`). Defina então `SERVER_PORT=<esse valor>`.
- `SERVER_URL` deve ser a URL pública que você usa para acessar a API (com HTTPS se houver SSL), para que webhooks e links gerados pela API funcionem.

---

## Passo 6: Reiniciar e testar

1. Salve as variáveis de ambiente e **reinicie** (ou faça um novo deploy) da aplicação Node.js no hPanel.
2. Acesse no navegador (ou via Postman/Insomnia):
   - `https://sua-url/SERVER_URL/instance/fetchInstances`
   - Header: `apikey: SUA_AUTHENTICATION_API_KEY`

Se retornar lista (mesmo vazia) ou pedido de criação de instância, a API está online.

Para criar uma instância e conectar WhatsApp, use a documentação oficial:  
[https://doc.evolution-api.com](https://doc.evolution-api.com).

---

## Resumo rápido

1. Criar banco MySQL no hPanel e anotar connection string.
2. Criar app Node.js (GitHub ou ZIP) com build `npm run build` e start `npm run start:prod`.
3. Configurar variáveis: `DATABASE_PROVIDER=mysql`, `DATABASE_CONNECTION_URI`, `AUTHENTICATION_API_KEY`, `SERVER_PORT`, `SERVER_URL`, cache local se não tiver Redis.
4. Rodar migrations (SSH, script de build ou local apontando para o MySQL remoto).
5. Reiniciar a aplicação e testar a URL da API.

---

## Observações

- **Redis**: não é obrigatório. Com `CACHE_REDIS_ENABLED=false` e `CACHE_LOCAL_ENABLED=true` a API funciona só com cache em memória.
- **SSL**: se o Hostinger já servir a app por HTTPS, use `SERVER_URL` com `https://`.
- **Limites**: em planos shared, processos longos e uso de memória podem ter limites; para muitos usuários/instâncias, considere VPS ou Cloud com mais recursos.
- **Documentação oficial**: [Evolution API Docs](https://doc.evolution-api.com) e [Hostinger – Node.js](https://www.hostinger.com/support/how-to-deploy-a-nodejs-website-in-hostinger/).
