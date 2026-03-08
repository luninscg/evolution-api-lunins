# 503 "Server busy" no Hostinger – o que fazer

Se a Evolution API continua retornando **503 Service Unavailable** depois de configurar variáveis e redeploy, siga na ordem:

---

## 1. Confirmar que a app sobe (Runtime logs)

No painel da aplicação Node.js → **Runtime logs**:

- **Aparece** algo como `HTTP - ON: 8080 (0.0.0.0)`?  
  → A aplicação está rodando. O problema é a **porta** ou o proxy (passos 2 e 3).
- **Não aparece** essa linha ou há **erro** antes?  
  → A aplicação está caindo (banco, memória, etc.). Veja o erro no log e corrija (ex.: `DATABASE_CONNECTION_URI`, limite de memória).

---

## 2. Descobrir a porta que o Hostinger usa

O proxy do Hostinger encaminha para **uma porta** onde sua app deve estar escutando. Se a app escutar em outra, dá 503.

- No **Dashboard** da aplicação Node.js ou em **Settings / Configurações**, procure:
  - **Port** / **Application port** / **PORT**
  - Ou texto do tipo “Your app runs on port X”
- Defina nas **variáveis de ambiente**:
  - **`PORT`** = valor mostrado (ex.: `3000`, `8080`, `5000`)
  - **`SERVER_PORT`** = mesmo valor
- Salve e faça **Redeploy**. Teste de novo.

Se **não achar** a porta em lugar nenhum, vá para o passo 3.

---

## 3. Testar portas comuns (3000, 5000, 8080)

Se o painel não mostrar a porta, teste na ordem:

1. Variáveis: **`PORT`** = **`3000`**, **`SERVER_PORT`** = **`3000`** → Redeploy → testar a URL.
2. Se ainda 503: **`PORT`** = **`5000`**, **`SERVER_PORT`** = **`5000`** → Redeploy → testar.
3. Se ainda 503: **`PORT`** = **`8080`**, **`SERVER_PORT`** = **`8080`** → Redeploy → testar.

Use sempre a **mesma** URL (sem porta na barra do navegador), por exemplo:

`https://orchid-pheasant-393325.hostingersite.com/health`

ou

`https://orchid-pheasant-393325.hostingersite.com/instance/fetchInstances`  
(com header `apikey: SUA_CHAVE`).

---

## 4. Falar com o suporte Hostinger

Se depois disso ainda der 503:

- Abra o **suporte** (chat ou ticket) e pergunte algo como:

  **“Minha aplicação Node.js no domínio [seu-dominio] está retornando 503. Em qual porta (PORT) a aplicação deve escutar para o proxy encaminhar corretamente? A app já está em execução (vejo ‘HTTP - ON’ nos logs).”**

- Informe que a aplicação usa **Express** e que você já testou **PORT** 3000, 5000 e 8080.

Com a porta correta em **PORT** e **SERVER_PORT**, o 503 costuma parar.

---

## 5. Endpoint de health

A API passou a expor **GET /health**, que responde rápido e sem dependências externas. Você pode usar para testar:

- **URL:** `https://seu-dominio.hostingersite.com/health`
- **Resposta esperada:** `{"status":"ok","timestamp":"..."}`

Se **/health** responder 200 e o resto ainda der 503, o proxy está alcançando a app; aí o problema pode ser rota, timeout ou outra configuração. Se **/health** também der 503, o proxy ainda não está acertando a porta (volte aos passos 2 e 3).

---

## Resumo

1. Ver **Runtime logs** (app sobe? em qual porta?).
2. Descobrir a **porta** no painel ou testando **3000**, **5000**, **8080** em **PORT** e **SERVER_PORT**.
3. **Redeploy** após cada alteração de variáveis.
4. Se nada resolver, **suporte Hostinger** com a pergunta sobre a porta correta.
5. Usar **/health** para testar se o proxy está alcançando a aplicação.
