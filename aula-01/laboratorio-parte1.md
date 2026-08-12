# Laboratório Parte 1 — Primeiros Passos com Git

**Tempo estimado:** 120 minutos

## Missão: Estabelecer o Controle de Versão para o Código da TechNova

> O CTO da TechNova autorizou a equipe de Platform Engineering a implementar Git como sistema de controle de versão oficial da empresa. Sua missão é configurar o ambiente, criar o primeiro repositório e demonstrar o fluxo completo de trabalho com Git — da inicialização local até a publicação no GitHub.

---

## Pré-requisitos

- Git instalado na máquina ([download aqui](https://git-scm.com/downloads))
- Conta no GitHub ([criar conta](https://github.com/signup))
- Terminal (Git Bash no Windows, Terminal no macOS/Linux)
- Editor de texto (VS Code recomendado)

---

## Parte 1 — Configuração Inicial do Git (10 minutos)

### Passo 1.1: Verificar instalação do Git

```bash
git --version
```

**Resultado esperado:**
```
git version 2.x.x
```

Qualquer versão 2.x é compatível com este laboratório.

### Passo 1.2: Configurar identidade

Configure seu nome e e-mail — estas informações aparecerão em todos os seus commits:

```bash
git config --global user.name "Seu Nome Completo"
git config --global user.email "seu.email@exemplo.com"
```

### Passo 1.3: Configurar editor padrão

```bash
git config --global core.editor "code --wait"
```

### Passo 1.4: Configurar branch padrão como `main`

```bash
git config --global init.defaultBranch main
```

### Passo 1.5: Verificar configurações

```bash
git config --list
```

**Resultado esperado:** Você deve ver `user.name`, `user.email`, `core.editor` e `init.defaultBranch` listados.

✅ **Checkpoint 1:** Git configurado com nome, e-mail e branch padrão `main`.

---

## Parte 2 — Criando o Primeiro Repositório e Primeiros Commits (20 minutos)

### Passo 2.1: Criar diretório do projeto

```bash
mkdir app-technova
cd app-technova
```

### Passo 2.2: Inicializar o repositório Git

```bash
git init
```

**Resultado esperado:**
```
Initialized empty Git repository in .../app-technova/.git/
```

### Passo 2.3: Verificar o status inicial

```bash
git status
```

**Resultado esperado:**
```
On branch main

No commits yet

nothing to commit (create/copy files and use "git add" to track)
```

### Passo 2.4: Criar o arquivo README.md

Crie o arquivo `README.md` com o seguinte conteúdo:

```markdown
# TechNova API

API de gerenciamento de pedidos da TechNova.

## Status

🚧 Em desenvolvimento

## Equipe

- Platform Engineering Team
```

### Passo 2.5: Verificar que o Git detectou o novo arquivo

```bash
git status
```

**Resultado esperado:**
```
On branch main

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        README.md

nothing added to commit but untracked files present (use "git add" to track)
```

O arquivo aparece em vermelho como "Untracked files" — o Git sabe que existe, mas ainda não está rastreando.

### Passo 2.6: Adicionar ao staging e commitar

```bash
git add README.md
git status
```

**Resultado esperado:** O arquivo aparece em verde (staged), pronto para commit.

```bash
git commit -m "docs: adiciona README inicial do projeto"
```

**Resultado esperado:**
```
[main (root-commit) abc1234] docs: adiciona README inicial do projeto
 1 file changed, 11 insertions(+)
 create mode 100644 README.md
```

### Passo 2.7: Verificar o histórico

```bash
git log --oneline
```

**Resultado esperado:**
```
abc1234 docs: adiciona README inicial do projeto
```

✅ **Checkpoint 2:** Primeiro commit criado com sucesso. O histórico mostra a hash e a mensagem.

---

## Parte 3 — Trabalhando com Arquivos e .gitignore (20 minutos)

### Passo 3.1: Criar a estrutura do projeto

```bash
mkdir src
```

Crie o arquivo `src/index.js`:

```javascript
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get('/', (req, res) => {
  res.json({ 
    message: 'TechNova API - Online',
    version: '1.0.0'
  });
});

app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});
```

### Passo 3.2: Criar o package.json

Crie o arquivo `package.json`:

```json
{
  "name": "app-technova",
  "version": "1.0.0",
  "description": "API de gerenciamento de pedidos da TechNova",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js"
  },
  "dependencies": {
    "express": "4.18.2"
  }
}
```

### Passo 3.3: Criar o .gitignore

Crie o arquivo `.gitignore`:

```gitignore
# Dependências
node_modules/

# Variáveis de ambiente
.env

# Logs
*.log

# Arquivos de build
dist/
build/

# Sistema operacional
.DS_Store
Thumbs.db
```

### Passo 3.4: Simular o que aconteceria SEM .gitignore

Vamos criar um diretório que deveria ser ignorado para demonstrar o .gitignore em ação:

```bash
mkdir node_modules
echo "fake dependency" > node_modules/fake-package.txt
```

### Passo 3.5: Verificar o status

```bash
git status
```

**Resultado esperado:** O `node_modules/` **NÃO aparece** na lista — o `.gitignore` está funcionando! Você verá apenas:

```
Untracked files:
        .gitignore
        package.json
        src/
```

### Passo 3.6: Adicionar tudo ao staging e commitar

```bash
git add .
git status
```

Verifique que `node_modules/` não está no staging. Em seguida:

```bash
git commit -m "feat: adiciona estrutura inicial do projeto com Express"
```

### Passo 3.7: Criar um arquivo de variáveis de ambiente (que deve ser ignorado)

```bash
echo "PORT=3000" > .env
echo "DB_PASSWORD=super_secreto_123" >> .env
git status
```

**Resultado esperado:** O `.env` **NÃO aparece** — está sendo ignorado pelo `.gitignore`. Segredos protegidos!

### Passo 3.8: Verificar o histórico atualizado

```bash
git log --oneline
```

**Resultado esperado:**
```
def5678 feat: adiciona estrutura inicial do projeto com Express
abc1234 docs: adiciona README inicial do projeto
```

✅ **Checkpoint 3:** Dois commits no histórico. O `.gitignore` protege `node_modules/` e `.env` de serem rastreados.

---

## Parte 4 — Branches e Merge (30 minutos)

### Passo 4.1: Verificar a branch atual

```bash
git branch
```

**Resultado esperado:**
```
* main
```

O asterisco indica a branch ativa.

### Passo 4.2: Criar uma branch de feature

```bash
git checkout -b feature/health-check
```

**Resultado esperado:**
```
Switched to a new branch 'feature/health-check'
```

### Passo 4.3: Verificar as branches existentes

```bash
git branch
```

**Resultado esperado:**
```
* feature/health-check
  main
```

### Passo 4.4: Implementar a funcionalidade na branch

Edite o arquivo `src/index.js` e adicione o seguinte **antes** do `app.listen`:

```javascript
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    timestamp: new Date().toISOString(),
    service: 'app-technova',
    version: '1.0.0'
  });
});
```

### Passo 4.5: Commitar na branch de feature

```bash
git add src/index.js
git commit -m "feat: adiciona endpoint de health check"
```

### Passo 4.6: Adicionar mais uma funcionalidade na mesma branch

Adicione outro endpoint em `src/index.js` (antes do `app.listen`):

```javascript
app.get('/info', (req, res) => {
  res.json({
    empresa: 'TechNova',
    projeto: 'API de Gerenciamento de Pedidos',
    equipe: 'Platform Engineering',
    ambiente: process.env.NODE_ENV || 'development'
  });
});
```

```bash
git add src/index.js
git commit -m "feat: adiciona endpoint de informações da API"
```

### Passo 4.7: Verificar que as mudanças estão isoladas na branch

```bash
git log --oneline
```

**Resultado esperado:** 4 commits visíveis.

Agora volte para a `main`:

```bash
git checkout main
git log --oneline
```

**Resultado esperado:** Apenas 2 commits! Os endpoints `/health` e `/info` **não existem** na `main`.

Verifique o conteúdo do arquivo:

```bash
cat src/index.js
```

Os endpoints novos não estão lá — estão isolados na branch `feature/health-check`.

### Passo 4.8: Fazer merge da feature

```bash
git merge feature/health-check
```

**Resultado esperado:**
```
Updating def5678..ghi9012
Fast-forward
 src/index.js | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)
```

### Passo 4.9: Verificar o merge

```bash
git log --oneline --graph --all
```

**Resultado esperado:** Todos os commits agora estão na `main`. Como não houve divergência, foi um merge **fast-forward**.

### Passo 4.10: Limpar — deletar a branch finalizada

```bash
git branch -d feature/health-check
```

**Resultado esperado:**
```
Deleted branch feature/health-check (was ghi9012).
```

### Passo 4.11: (Opcional) Simular um conflito de merge

Para entender conflitos, vamos simular:

```bash
# Criar branch A
git checkout -b feature/mensagem-v2

# Modificar a mensagem da rota principal
# No src/index.js, altere a message de '/' para:
# message: 'TechNova API v2 - Online'
```

Edite o `message` na rota `/` para `'TechNova API v2 - Online'`.

```bash
git add src/index.js
git commit -m "feat: atualiza mensagem para v2"
git checkout main
```

Agora, na `main`, faça outra alteração no mesmo local:

```bash
# No src/index.js, altere a message de '/' para:
# message: 'TechNova API - Sistema de Pedidos'
```

Edite o `message` na rota `/` para `'TechNova API - Sistema de Pedidos'`.

```bash
git add src/index.js
git commit -m "feat: atualiza mensagem com descrição do sistema"
```

Agora tente o merge:

```bash
git merge feature/mensagem-v2
```

**Resultado esperado:** CONFLITO! O Git marca o arquivo:

```
Auto-merging src/index.js
CONFLICT (content): Merge conflict in src/index.js
Automatic merge failed; fix conflicts and then commit the result.
```

Abra o arquivo e resolva o conflito (escolha uma das versões ou combine), remova os marcadores (`<<<<<<<`, `=======`, `>>>>>>>`), depois:

```bash
git add src/index.js
git commit -m "merge: resolve conflito na mensagem da API"
git branch -d feature/mensagem-v2
```

✅ **Checkpoint 4:** Experiência com criação de branch, merge fast-forward e (opcionalmente) resolução de conflitos.

---

## Parte 5 — Repositório Remoto no GitHub (25 minutos)

### Passo 5.1: Criar repositório no GitHub

1. Acesse [github.com/new](https://github.com/new)
2. Nome do repositório: `app-technova`
3. Visibilidade: **Público**
4. Deixe **sem** README, .gitignore ou licença (já temos localmente)
5. Clique em "Create repository"

### Passo 5.2: Conectar o repositório local ao remoto

```bash
git remote add origin https://github.com/SEU-USUARIO/app-technova.git
```

### Passo 5.3: Verificar o remoto configurado

```bash
git remote -v
```

**Resultado esperado:**
```
origin  https://github.com/SEU-USUARIO/app-technova.git (fetch)
origin  https://github.com/SEU-USUARIO/app-technova.git (push)
```

### Passo 5.4: Enviar os commits para o GitHub

```bash
git push -u origin main
```

**Resultado esperado:**
```
Enumerating objects: X, done.
Counting objects: 100% (X/X), done.
...
To https://github.com/SEU-USUARIO/app-technova.git
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'.
```

> **Nota sobre autenticação:** Na primeira vez, o GitHub pode pedir autenticação. Use um **Personal Access Token**:
> 1. GitHub → Settings → Developer Settings → Personal Access Tokens → Tokens (classic)
> 2. Gere um token com permissão `repo`
> 3. Use o token como senha no prompt de autenticação

### Passo 5.5: Verificar no GitHub

Acesse `https://github.com/SEU-USUARIO/app-technova` no navegador e confirme que:

- [ ] Todos os arquivos estão visíveis
- [ ] O README.md é renderizado na página inicial
- [ ] O histórico de commits está completo (aba "Commits")
- [ ] O `.env` e `node_modules/` **NÃO** aparecem (protegidos pelo .gitignore)

### Passo 5.6: Fazer uma alteração e sincronizar

Edite o `README.md` para adicionar informações sobre como rodar:

```markdown
## Como Executar

```bash
npm install
npm start
```
```

```bash
git add README.md
git commit -m "docs: adiciona instruções de execução ao README"
git push
```

Atualize a página no GitHub — a alteração deve aparecer imediatamente.

✅ **Checkpoint 5:** Repositório publicado no GitHub com todos os commits sincronizados.

---

## Parte 6 — Simulando Colaboração (15 minutos)

### Passo 6.1: Clone em outra pasta (simulando outro dev)

```bash
cd ..
git clone https://github.com/SEU-USUARIO/app-technova.git app-technova-rafael
cd app-technova-rafael
```

### Passo 6.2: Verificar que o clone está completo

```bash
git log --oneline
```

**Resultado esperado:** Todo o histórico de commits está presente — o Rafael (simulado) tem acesso completo ao projeto.

### Passo 6.3: Fazer uma alteração como "Rafael"

```bash
git config user.name "Rafael Silva"
git config user.email "rafael@technova.com"
```

Crie o arquivo `src/routes/orders.js`:

```bash
mkdir -p src/routes
```

```javascript
// src/routes/orders.js
const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.json({ 
    orders: [],
    message: 'Módulo de pedidos em construção'
  });
});

module.exports = router;
```

```bash
git add .
git commit -m "feat: adiciona estrutura inicial do módulo de pedidos"
git push
```

### Passo 6.4: Voltar ao repositório original e sincronizar

```bash
cd ../app-technova
git pull origin main
git log --oneline
```

**Resultado esperado:** O commit do "Rafael" agora aparece no seu repositório local!

### Passo 6.5: Verificar o arquivo criado pelo colega

```bash
cat src/routes/orders.js
```

O código do Rafael está disponível localmente. Isso demonstra o fluxo completo de colaboração.

✅ **Checkpoint 6:** Colaboração simulada com clone, push e pull funcionando. A equipe TechNova pode trabalhar em conjunto!

---

## Troubleshooting — Problemas Comuns

### ❌ Erro: `fatal: not a git repository`

**Causa:** Você está fora do diretório do repositório ou não executou `git init`.

**Solução:**
```bash
cd app-technova
# ou se ainda não inicializou:
git init
```

### ❌ Erro: `fatal: remote origin already exists`

**Causa:** O remoto `origin` já foi configurado anteriormente.

**Solução:**
```bash
git remote remove origin
git remote add origin https://github.com/SEU-USUARIO/app-technova.git
```

### ❌ Erro: `error: failed to push some refs`

**Causa:** O repositório remoto tem commits que não existem localmente.

**Solução:**
```bash
git pull origin main --rebase
git push origin main
```

### ❌ Erro: `merge conflict`

**Causa:** Ambas as branches alteraram o mesmo trecho do mesmo arquivo.

**Solução:**
1. Abra o arquivo com conflito (marcado com `<<<<<<<`, `=======`, `>>>>>>>`)
2. Edite manualmente escolhendo qual versão manter
3. Remova os marcadores de conflito
4. Execute `git add <arquivo>` e `git commit`

### ❌ Erro de autenticação no push

**Causa:** GitHub não aceita mais senha — precisa de token.

**Solução:**
1. GitHub → Settings → Developer Settings → Personal Access Tokens → Tokens (classic)
2. Gere um token com permissão `repo`
3. Use o token como senha no prompt
4. Dica: configure o credential helper para não pedir toda vez:
   ```bash
   git config --global credential.helper store
   ```

### ❌ Erro: `fatal: The current branch main has no upstream branch`

**Causa:** A branch local não está vinculada a uma branch remota.

**Solução:**
```bash
git push -u origin main
```

---

## Validação Final — Parte 1

Ao concluir este laboratório, você deve ter:

- [ ] Git configurado com nome, e-mail e branch padrão
- [ ] Repositório `app-technova` inicializado com pelo menos 4 commits
- [ ] Arquivo `.gitignore` configurado e protegendo `node_modules/` e `.env`
- [ ] Experiência com criação de branch e merge (fast-forward)
- [ ] Repositório publicado no GitHub com todos os commits
- [ ] Clone funcional demonstrando colaboração e distribuição do histórico
- [ ] (Opcional) Experiência com resolução de conflitos de merge

---

*Excelente! A TechNova agora tem controle de versão. Na Parte 2 do laboratório, vamos resolver o segundo problema: "funciona na minha máquina" — containerizando a API com Docker.*
