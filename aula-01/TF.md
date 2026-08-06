# Trabalho de Fixação (TF) — Aula 01: Portfólio DevOps com Git e Docker

## Desafio

Crie seu **repositório portfólio DevOps** no GitHub, demonstrando domínio dos dois pilares aprendidos nesta aula: versionamento com Git (workflow com branches) e containerização com Docker (Dockerfile funcional). Este repositório será utilizado ao longo de toda a disciplina para documentar seu progresso.

## Informações de Entrega

| Item | Detalhe |
|------|---------|
| **Prazo** | 1 semana a partir da data da aula |
| **Forma de entrega** | Pull Request (PR) para o repositório da disciplina |
| **Pasta de entrega** | `entregas/aula-01/RA/` (substitua RA pelo seu número de matrícula) |
| **Conteúdo do PR** | Arquivo `entrega.md` com link do repositório + evidências |

### Como Entregar via Pull Request

1. Faça um **fork** do repositório da disciplina (se ainda não fez)
2. Clone o seu fork localmente
3. Crie a pasta `entregas/aula-01/SEU-RA/`
4. Adicione o arquivo `entrega.md` (modelo abaixo)
5. Faça commit e push para o seu fork
6. Abra um **Pull Request** para o repositório original

**Modelo do arquivo `entrega.md`:**

```markdown
# Entrega — Aula 01: Fundamentos de Git e Docker

**Aluno:** [Seu nome completo]  
**RA:** [Seu RA]  
**Data:** [Data da entrega]

## Repositório

- URL: https://github.com/SEU-USUARIO/unifaat-devops-portfolio

## Evidências

- [ ] Repositório público com estrutura completa
- [ ] Mínimo de 5 commits demonstrando workflow Git
- [ ] Dockerfile funcional
- [ ] Container rodando (evidência abaixo)

## Evidência de Container Rodando

[Cole aqui o output do `docker ps` ou screenshot]
```

## Instruções Detalhadas

### 1. Criar o Repositório no GitHub

- Nome do repositório: `unifaat-devops-portfolio`
- Visibilidade: **Público**
- Inicializar **sem** README (você criará manualmente)

### 2. Configurar o Repositório Localmente

```bash
mkdir unifaat-devops-portfolio
cd unifaat-devops-portfolio
git init
```

### 3. Criar a Estrutura Inicial (Branch main)

**README.md** (na raiz):

```markdown
# Portfólio DevOps — UniFAAT 2026-2

**Aluno:** [Seu nome completo]  
**RA:** [Seu RA]  
**Disciplina:** DevOps — Centro Universitário UniFAAT  
**Professor:** Alexandre Tavares  
**Semestre:** 2026-2

## Sobre

Repositório de atividades e projetos da disciplina de DevOps.
Aqui documento minha evolução desde os fundamentos de Git e Docker até pipelines completas de CI/CD.

## Estrutura

- `aula-01/` — Fundamentos de Git e Docker

## Aprendizados

[Atualize esta seção a cada aula com seus principais aprendizados]
```

**.gitignore** (na raiz):

```gitignore
# Dependências
node_modules/

# Variáveis de ambiente
.env

# Logs
*.log

# Sistema operacional
.DS_Store
Thumbs.db

# Build
dist/
build/
```

Commit inicial:

```bash
git add README.md .gitignore
git commit -m "docs: estrutura inicial do portfólio DevOps"
```

### 4. Criar a Aplicação com Feature Branch

Crie uma branch para desenvolver a aplicação:

```bash
git checkout -b feature/aula-01-app
```

Crie a pasta e os arquivos da aplicação:

```bash
mkdir -p aula-01/app
```

**`aula-01/app/server.js`:**

```javascript
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    servico: 'DevOps Portfolio API',
    aluno: 'SEU NOME AQUI',
    ra: 'SEU RA AQUI',
    aula: '01 - Fundamentos de Git e Docker',
    status: 'online',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    uptime: process.uptime(),
    version: '1.0.0'
  });
});

app.listen(PORT, () => {
  console.log(`Portfolio API rodando na porta ${PORT}`);
});
```

**`aula-01/app/package.json`:**

```json
{
  "name": "devops-portfolio-aula01",
  "version": "1.0.0",
  "description": "Aplicação da Aula 01 - Fundamentos de Git e Docker",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "4.18.2"
  }
}
```

Commit da aplicação:

```bash
git add aula-01/app/
git commit -m "feat: cria aplicação Express para aula 01"
```

### 5. Adicionar Dockerfile e .dockerignore

**`aula-01/app/Dockerfile`:**

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install --production

COPY . .

EXPOSE 3000

CMD ["node", "server.js"]
```

**`aula-01/app/.dockerignore`:**

```dockerignore
node_modules/
.git/
*.log
.env
```

Commit dos arquivos Docker:

```bash
git add aula-01/app/Dockerfile aula-01/app/.dockerignore
git commit -m "feat: adiciona Dockerfile e .dockerignore para containerização"
```

### 6. Criar README da Aula com Aprendizados Pessoais

**`aula-01/README.md`:**

```markdown
# Aula 01 — Fundamentos de Git e Docker

## O que aprendi

- [Descreva 3-5 conceitos que aprendeu sobre Git]
- [Descreva 3-5 conceitos que aprendeu sobre Docker]

## Comandos Git praticados

- [Liste os comandos Git que utilizou]

## Comandos Docker praticados

- [Liste os comandos Docker que utilizou]

## Como executar este container

```bash
cd aula-01/app
docker build -t portfolio-aula01:1.0 .
docker run -d -p 3000:3000 portfolio-aula01:1.0
curl http://localhost:3000
```

## Dificuldades encontradas

- [Descreva dificuldades e como resolveu]
```

```bash
git add aula-01/README.md
git commit -m "docs: adiciona README com aprendizados da aula 01"
```

### 7. Construir e Testar o Container

```bash
cd aula-01/app
docker build -t portfolio-aula01:1.0 .
docker run -d --name portfolio-test -p 3000:3000 portfolio-aula01:1.0
```

Verifique:

```bash
curl http://localhost:3000
curl http://localhost:3000/health
docker ps
```

### 8. Capturar Evidência de Execução

Capture a evidência de que o container roda corretamente. Escolha **uma** opção:

**Opção A — Arquivo de logs:**

```bash
docker logs portfolio-test > ../docker-logs.txt 2>&1
echo "---" >> ../docker-logs.txt
echo "Container running:" >> ../docker-logs.txt
docker ps --filter "name=portfolio-test" >> ../docker-logs.txt
echo "---" >> ../docker-logs.txt
echo "API Response:" >> ../docker-logs.txt
curl -s http://localhost:3000 >> ../docker-logs.txt
```

**Opção B — Screenshot:**
- Screenshot mostrando `docker ps` e a resposta da API no navegador
- Salve como `aula-01/evidencia.png`

```bash
cd ..
git add docker-logs.txt  # ou evidencia.png
git commit -m "docs: adiciona evidência de container rodando"
```

### 9. Limpar Container de Teste

```bash
docker stop portfolio-test
docker rm portfolio-test
```

### 10. Merge e Publicação

```bash
cd ..  # Voltar para a raiz do portfolio
git checkout main
git merge feature/aula-01-app
```

Conectar ao GitHub e fazer push:

```bash
git remote add origin https://github.com/SEU-USUARIO/unifaat-devops-portfolio.git
git push -u origin main
```

## Entregáveis Obrigatórios

O repositório `unifaat-devops-portfolio` deve conter:

- [ ] `README.md` na raiz com nome, RA, disciplina e professor
- [ ] `.gitignore` na raiz configurado corretamente
- [ ] `aula-01/README.md` com aprendizados pessoais (não template)
- [ ] `aula-01/app/server.js` — aplicação Express funcional
- [ ] `aula-01/app/package.json` — com dependência Express
- [ ] `aula-01/app/Dockerfile` — funcional e otimizado
- [ ] `aula-01/app/.dockerignore` — configurado
- [ ] Evidência de container rodando (`docker-logs.txt` ou `evidencia.png`)
- [ ] Mínimo de **5 commits** demonstrando workflow Git
- [ ] Evidência de uso de branch (feature branch + merge)

## Critérios de Avaliação

| # | Critério | Peso | Verificação |
|---|----------|:---:|---|
| 1 | Repositório público no GitHub com nome correto | 10% | URL acessível |
| 2 | Estrutura de pastas organizada | 10% | Padrão solicitado |
| 3 | Workflow Git com branches (feature → merge) | 15% | Histórico do Git |
| 4 | Mínimo de 5 commits com mensagens descritivas (Conventional Commits) | 15% | `git log` |
| 5 | Aplicação Express funcional com endpoints / e /health | 10% | Código correto |
| 6 | Dockerfile funcional e otimizado (camadas) | 15% | Build sem erros |
| 7 | .gitignore e .dockerignore configurados | 10% | Arquivos presentes |
| 8 | Evidência de container rodando | 10% | Logs ou screenshot |
| 9 | README pessoal com aprendizados reais | 5% | Conteúdo não-template |

**Total: 100%**

## Dicas

- **Use Conventional Commits** nas mensagens: `feat:`, `docs:`, `fix:`, `chore:`
- **Não delete a branch** `feature/aula-01-app` antes de fazer push — ela serve como evidência do workflow
- **Teste o Dockerfile localmente** antes de fazer push — garanta que `docker build` e `docker run` funcionam
- **Não commite `node_modules/`** — verifique que o `.gitignore` está configurado antes do primeiro `git add`
- **Personalize os READMEs** — respostas genéricas ou copiadas do template terão nota reduzida
- **Se der erro no build:** leia a mensagem de erro, verifique o Dockerfile e o `.dockerignore`, consulte a seção de Troubleshooting do laboratório
- Este repositório será usado em **TODAS as aulas seguintes** — organize-o bem desde o início

## Bônus (Opcional)

Para quem quiser ir além:

- Adicionar endpoint `/about` com informações adicionais
- Usar variáveis de ambiente (`ENV`) no Dockerfile
- Criar um `docker-compose.yml` simples (pré-visualização da próxima aula)
- Adicionar badge de status no README do repositório

---

*Este portfólio será a prova viva da sua jornada de Platform Engineer na TechNova. Cuide bem dele — ele cresce a cada aula!*
