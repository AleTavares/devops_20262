# TechNova API

API de gestão de pedidos da TechNova, usada como base nos laboratórios de CI/CD (Aula 08 em diante).

> **📦 Pasta base para os labs.** Em vez de criar cada arquivo à mão, **copie esta pasta inteira** para dentro da pasta da aula no seu repositório `unifaat-devops-portfolio`. Veja a seção [Como usar nos labs](#como-usar-nos-labs).

---

## Conteúdo

```
technova-api/
├── server.js              # API Express (health check + CRUD de orders)
├── package.json           # Dependências e scripts (start, test, lint, build)
├── .eslintrc.json         # Configuração do ESLint
├── Dockerfile             # Imagem multi-stage, usuário não-root
├── .dockerignore          # Exclusões do contexto de build
├── .gitignore             # node_modules, coverage, .env, etc.
├── __tests__/
│   └── server.test.js     # Testes Jest (health + orders)
└── README.md              # Este arquivo
```

---

## Rotas da API

| Método | Rota | Descrição |
|--------|------|-----------|
| `GET` | `/health` | Health check (status, timestamp, versão) |
| `GET` | `/api/orders` | Lista todos os pedidos |
| `GET` | `/api/orders/:id` | Busca um pedido pelo id (404 se não existir) |
| `POST` | `/api/orders` | Cria um pedido (valida `product` e `quantity`) |

---

## Quick Start

```bash
npm install
npm start        # inicia em http://localhost:3000
```

Teste rápido:

```bash
curl http://localhost:3000/health
curl http://localhost:3000/api/orders
```

## Scripts Disponíveis

| Comando | Descrição |
|---------|-----------|
| `npm start` | Inicia o servidor |
| `npm test` | Roda os testes com coverage |
| `npm run test:ci` | Roda os testes em modo CI |
| `npm run lint` | Verifica o código com ESLint |
| `npm run lint:fix` | Corrige problemas de lint automaticamente |
| `npm run build` | Verificação de sintaxe (`node --check`) |

## Docker

```bash
docker build -t technova-api .
docker run -d -p 3000:3000 --name technova-api technova-api
curl http://localhost:3000/health
docker stop technova-api && docker rm technova-api
```

---

## Como usar nos labs

No laboratório da Aula 08, a estrutura esperada é `aula-08/technova-api/` dentro do seu `unifaat-devops-portfolio`. Para começar sem recriar os arquivos, copie esta pasta:

```bash
# a partir da raiz do repositório da disciplina (devops_20262)
cp -r technova-api /caminho/para/unifaat-devops-portfolio/aula-08/technova-api

# ou, se você já está dentro do unifaat-devops-portfolio:
mkdir -p aula-08
cp -r /caminho/para/devops_20262/technova-api aula-08/technova-api
```

Depois:

```bash
cd aula-08/technova-api
npm install          # gera o package-lock.json (necessário para o CI com npm ci)
npm run lint
npm test
```

> **Importante:** rode `npm install` após copiar para gerar o `package-lock.json`. O workflow de CI usa `npm ci`, que exige esse arquivo commitado.

A partir daí, siga o laboratório para criar o workflow em `.github/workflows/` (na **raiz** do `unifaat-devops-portfolio`, não dentro de `aula-08/`).

---

## Tech Stack

- Node.js 20
- Express.js
- Jest + Supertest (testes)
- ESLint (linting)
- Docker
- GitHub Actions (CI)
