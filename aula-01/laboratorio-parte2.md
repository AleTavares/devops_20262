# Laboratório Parte 2 — Containerizando a API do Portfólio

**Tempo estimado:** 120 minutos

## Missão: Garantir que a API Rode de Forma Idêntica em Qualquer Ambiente

> A equipe de Platform Engineering acabou de implementar Git com sucesso (Parte 1). O código está versionado e seguro no GitHub no repositório `unifaat-devops-portfolio`. Agora é hora de atacar o segundo problema: eliminar o "funciona na minha máquina". A solução: containerizar a API usando Docker. Ao final deste laboratório, qualquer membro da equipe poderá rodar a aplicação com um único comando, independente do sistema operacional ou configurações locais.

---

## Pré-requisitos

- Docker Desktop instalado e rodando ([download aqui](https://www.docker.com/products/docker-desktop/))
- Laboratório Parte 1 concluído (repositório `unifaat-devops-portfolio` com código no GitHub)
- Terminal (Git Bash no Windows, Terminal no macOS/Linux)
- Editor de texto (VS Code recomendado)

> **Nota:** Se você não completou a Parte 1, clone o repositório base:
> ```bash
> git clone https://github.com/SEU-USUARIO/unifaat-devops-portfolio.git
> cd unifaat-devops-portfolio
> ```

---

## Parte 1 — Verificando a Instalação do Docker (10 minutos)

### Passo 1.1: Verificar que o Docker está instalado

```bash
docker --version
```

**Resultado esperado:**
```
Docker version 24.x.x, build xxxxxxx
```

Qualquer versão 24+ é compatível.

### Passo 1.2: Verificar que o Docker Engine está rodando

```bash
docker info
```

Se retornar informações do sistema (Server Version, Storage Driver, etc.), o Docker está funcionando. Se retornar erro de conexão, inicie o Docker Desktop.

### Passo 1.3: Testar com um container de exemplo

```bash
docker run hello-world
```

**Resultado esperado:**
```
Hello from Docker!
This message shows that your installation appears to be working correctly.
...
```

### Passo 1.4: Verificar o Docker Compose (incluído no Docker Desktop)

```bash
docker compose version
```

**Resultado esperado:**
```
Docker Compose version v2.x.x
```

✅ **Checkpoint 1:** Docker instalado e funcional. Engine rodando corretamente.

---

## Parte 2 — Explorando Imagens do Docker Hub (15 minutos)

### Passo 2.1: Baixar a imagem oficial do Node.js

```bash
docker pull node:20-alpine
```

> **Por que `alpine`?** Alpine Linux é uma distribuição minimalista (~5MB base). Imagens Alpine são muito menores que as baseadas em Debian/Ubuntu, resultando em builds mais rápidos e containers mais leves.

### Passo 2.2: Verificar a imagem baixada

```bash
docker images
```

**Resultado esperado:**
```
REPOSITORY    TAG          IMAGE ID       CREATED        SIZE
node          20-alpine    xxxxxxxxxxxx   X days ago     ~180MB
hello-world   latest       xxxxxxxxxxxx   X months ago   ~13kB
```

Observe o tamanho da imagem `node:20-alpine` (~180MB). Para comparação, a `node:20` (Debian) tem ~1GB.

### Passo 2.3: Rodar Node.js dentro de um container

```bash
docker run -it --rm node:20-alpine node -e "console.log('Node.js ' + process.version + ' rodando dentro do container!')"
```

**Resultado esperado:**
```
Node.js v20.x.x rodando dentro do container!
```

**Flags utilizadas:**
- `-it`: modo interativo com terminal
- `--rm`: remove o container automaticamente ao finalizar

### Passo 2.4: Comparar a versão do Node.js no container vs. local

```bash
# Versão dentro do container
docker run -it --rm node:20-alpine node --version

# Versão no seu host (se tiver Node instalado)
node --version
```

**Ponto importante:** Dentro do container, a versão é **sempre** `v20.x.x`, independente do que está instalado na sua máquina host. Isso é exatamente o que precisamos para resolver o problema da TechNova!

### Passo 2.5: Explorar o sistema de arquivos do Alpine

```bash
docker run -it --rm node:20-alpine sh -c "cat /etc/os-release"
```

**Resultado esperado:**
```
NAME="Alpine Linux"
ID=alpine
VERSION_ID=3.x.x
...
```

✅ **Checkpoint 2:** Imagem Node.js baixada e testada. Versão consistente independente do host.

---

## Parte 3 — Escrevendo o Dockerfile (25 minutos)

### Passo 3.1: Navegar até o repositório do projeto

```bash
cd unifaat-devops-portfolio
```

> **Continuidade da Parte 1:** Este é o mesmo repositório que você criou e publicou no GitHub. Agora vamos adicionar containerização ao projeto.

### Passo 3.2: Verificar a estrutura atual do projeto

```bash
ls -la aula-01/app/
```

**Estrutura esperada (da Parte 1):**
```
unifaat-devops-portfolio/
├── aula-01/
│   └── app/
│       ├── server.js
│       ├── package.json
│       └── routes/
│           └── orders.js
├── .gitignore
├── .env
├── node_modules/  (se fez npm install localmente)
└── README.md
```

### Passo 3.3: Criar o arquivo `.dockerignore`

Crie o arquivo `aula-01/app/.dockerignore`:

```dockerignore
# Dependências (serão instaladas no container)
node_modules/
npm-debug.log

# Git (não precisa dentro do container)
.git/
.gitignore

# Variáveis de ambiente locais
.env

# Logs
*.log

# Documentação (não precisa no container de produção)
README.md

# Docker files (evita loop)
.dockerignore
Dockerfile
```

> **Por que `.dockerignore`?** Evita copiar arquivos desnecessários para dentro da imagem. Isso reduz o tamanho da imagem e o tempo de build. O `node_modules/` local, por exemplo, pode conter binários compilados para o SEU sistema operacional — dentro do container (Alpine Linux), as dependências precisam ser instaladas do zero.

### Passo 3.4: Criar o Dockerfile

Crie o arquivo `aula-01/app/Dockerfile` (sem extensão):

```dockerfile
# ==================================================
# Dockerfile - Portfolio DevOps API (Aula 01)
# Containeriza a API do portfólio DevOps
# ==================================================

# 1. Imagem base: Node.js 20 com Alpine Linux (leve)
FROM node:20-alpine

# 2. Definir diretório de trabalho dentro do container
WORKDIR /app

# 3. Copiar apenas arquivos de dependências primeiro
#    (OTIMIZAÇÃO: cache de camadas - se package.json não mudar,
#    a camada de npm install é reaproveitada do cache)
COPY package*.json ./

# 4. Instalar dependências de produção
RUN npm install --production

# 5. Copiar o restante do código-fonte
COPY . .

# 6. Documentar a porta que a aplicação utiliza
EXPOSE 3000

# 7. Comando para iniciar a aplicação
CMD ["node", "server.js"]
```

### Passo 3.5: Entender a estratégia de otimização de camadas

A ordem das instruções no Dockerfile é **crucial** para performance. Observe que copiamos `package.json` **antes** do código-fonte:

```
Cenário: Você alterou apenas o código em src/index.js

  Camada 1 (FROM node:20-alpine) ...... ♻️ cache
  Camada 2 (WORKDIR /app) ............. ♻️ cache
  Camada 3 (COPY package*.json ./) .... ♻️ cache (package.json não mudou!)
  Camada 4 (RUN npm install) .......... ♻️ cache (dependências iguais!)
  Camada 5 (COPY . .) ................. 🔄 rebuild (código mudou)
  Camada 6 (CMD) ...................... 🔄 rebuild

Resultado: Apenas 2 camadas são reconstruídas!
Sem essa otimização: TODAS as camadas após o COPY . . seriam refeitas.
```

Isso economiza de segundos a minutos em cada build — especialmente quando `npm install` precisa baixar centenas de pacotes.

### Passo 3.6: Verificar se o package.json tem as dependências corretas

Abra o `aula-01/app/package.json` e confirme que tem o Express listado:

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

Se não tiver, adicione a seção `dependencies`.

✅ **Checkpoint 3:** Dockerfile e .dockerignore criados com estratégia de otimização de camadas.

---

## Parte 4 — Build e Execução do Container (25 minutos)

### Passo 4.1: Construir a imagem

```bash
cd aula-01/app
docker build -t portfolio-aula01:1.0 .
```

**Explicação:**
- `docker build`: comando para construir imagem
- `-t portfolio-aula01:1.0`: nomeia a imagem como `portfolio-aula01` com tag `1.0`
- `.`: usa o diretório atual como contexto de build (envia os arquivos para o Docker Engine)

**Resultado esperado:** Cada passo do Dockerfile é executado:
```
[+] Building X.Xs (8/8) FINISHED
 => [1/5] FROM node:20-alpine
 => [2/5] WORKDIR /app
 => [3/5] COPY package*.json ./
 => [4/5] RUN npm install --production
 => [5/5] COPY . .
 => exporting to image
 => => naming to docker.io/library/portfolio-aula01:1.0
```

### Passo 4.2: Verificar que a imagem foi criada

```bash
docker images | grep portfolio
```

**Resultado esperado:**
```
portfolio-aula01   1.0   xxxxxxxxxxxx   Just now   ~XXX MB
```

### Passo 4.3: Executar um segundo build (demonstrar cache)

Sem alterar nada, execute novamente:

```bash
docker build -t portfolio-aula01:1.0 .
```

**Resultado esperado:** O build é praticamente instantâneo! Todas as camadas vêm do cache:
```
 => CACHED [2/5] WORKDIR /app
 => CACHED [3/5] COPY package*.json ./
 => CACHED [4/5] RUN npm install --production
 => CACHED [5/5] COPY . .
```

### Passo 4.4: Rodar o container

```bash
docker run -d --name portfolio-container -p 3000:3000 portfolio-aula01:1.0
```

**Flags:**
- `-d`: executa em background (detached) — libera o terminal
- `--name portfolio-container`: nomeia o container para fácil referência
- `-p 3000:3000`: mapeia porta 3000 do host para porta 3000 do container

### Passo 4.5: Verificar que o container está rodando

```bash
docker ps
```

**Resultado esperado:**
```
CONTAINER ID   IMAGE                COMMAND                  STATUS         PORTS                    NAMES
xxxxxxxxxxxx   portfolio-aula01:1.0 "docker-entrypoint.s…"   Up X seconds   0.0.0.0:3000->3000/tcp   portfolio-container
```

### Passo 4.6: Testar a API

```bash
curl http://localhost:3000
```

**Resultado esperado:**
```json
{"message":"TechNova API - Online","version":"1.0.0"}
```

Ou acesse `http://localhost:3000` no navegador.

### Passo 4.7: Testar o endpoint de health check

```bash
curl http://localhost:3000/health
```

**Resultado esperado:**
```json
{"status":"healthy","timestamp":"2026-XX-XXTXX:XX:XX.XXXZ","service":"devops-portfolio-api","version":"1.0.0"}
```

### Passo 4.8: Verificar os logs do container

```bash
docker logs portfolio-container
```

**Resultado esperado:**
```
Servidor rodando na porta 3000
```

### Passo 4.9: Acompanhar logs em tempo real

```bash
docker logs -f portfolio-container
```

Abra outra aba do terminal e faça uma requisição:

```bash
curl http://localhost:3000
```

Você verá o log da requisição aparecer. Pressione `Ctrl+C` para sair.

✅ **Checkpoint 4:** A API do portfólio está rodando dentro de um container Docker, acessível na porta 3000. O mesmo container produz resultado idêntico em qualquer máquina!

---

## Parte 5 — Gerenciando Containers (20 minutos)

### Passo 5.1: Parar o container

```bash
docker stop portfolio-container
```

### Passo 5.2: Verificar que parou

```bash
docker ps
```

**Resultado esperado:** O container não aparece mais (mostra apenas containers rodando).

```bash
docker ps -a
```

**Resultado esperado:** O container aparece com status "Exited":
```
CONTAINER ID   IMAGE                STATUS                     NAMES
xxxxxxxxxxxx   portfolio-aula01:1.0 Exited (0) X seconds ago   portfolio-container
```

### Passo 5.3: Reiniciar o container

```bash
docker start portfolio-container
```

Teste novamente:
```bash
curl http://localhost:3000
```

Funciona! O container voltou ao estado anterior.

### Passo 5.4: Acessar o shell dentro do container

```bash
docker exec -it portfolio-container sh
```

**Agora você está DENTRO do container.** Explore:

```bash
# Ver diretório de trabalho
pwd
# Resultado: /app

# Listar arquivos da aplicação
ls -la
# Resultado: package.json, src/, node_modules/

# Verificar versão do Node.js (sempre a mesma!)
node --version
# Resultado: v20.x.x

# Verificar sistema operacional
cat /etc/os-release
# Resultado: Alpine Linux

# Ver dependências instaladas
ls node_modules/ | head -10

# Ver variáveis de ambiente
env | grep -i node

# Sair do container
exit
```

### Passo 5.5: Executar um comando direto no container (sem entrar no shell)

```bash
docker exec portfolio-container node -e "console.log('Memória usada:', Math.round(process.memoryUsage().heapUsed / 1024 / 1024) + 'MB')"
```

### Passo 5.6: Ver uso de recursos

```bash
docker stats portfolio-container --no-stream
```

**Resultado esperado:** Mostra CPU%, memória, rede e I/O do container.

### Passo 5.7: Parar e remover o container

```bash
docker stop portfolio-container
docker rm portfolio-container
```

### Passo 5.8: Rodar com --rm (auto-remove ao parar)

```bash
docker run -d --rm --name portfolio-temp -p 3000:3000 portfolio-aula01:1.0
```

Teste:
```bash
curl http://localhost:3000
```

Agora pare:
```bash
docker stop portfolio-temp
docker ps -a | grep portfolio-temp
```

**Resultado esperado:** Nada! O container foi automaticamente removido ao parar.

### Passo 5.9: Rodar com variável de ambiente customizada

```bash
docker run -d --rm --name portfolio-prod -p 3000:3000 -e NODE_ENV=production portfolio-aula01:1.0
```

Teste o endpoint `/info`:
```bash
curl http://localhost:3000/info
```

**Resultado esperado:** O campo `ambiente` mostra `"production"` (definido pela variável `-e NODE_ENV=production`).

```bash
docker stop portfolio-prod
```

✅ **Checkpoint 5:** Domínio completo de gerenciamento de containers — start, stop, exec, logs, rm, variáveis de ambiente.

---

## Parte 6 — Versionando os Arquivos Docker com Git (10 minutos)

> Esta parte conecta Docker de volta ao Git (Parte 1), fechando o ciclo completo.

### Passo 6.1: Verificar os novos arquivos

```bash
cd ../..  # Voltar para a raiz do unifaat-devops-portfolio
git status
```

**Resultado esperado:** `aula-01/app/Dockerfile` e `aula-01/app/.dockerignore` aparecem como untracked.

### Passo 6.2: Criar branch para a feature de Docker

```bash
git checkout -b feature/docker
```

### Passo 6.3: Adicionar e commitar os arquivos Docker

```bash
git add aula-01/app/Dockerfile aula-01/app/.dockerignore
git commit -m "feat: adiciona Dockerfile e .dockerignore para containerização"
```

### Passo 6.4: Fazer merge na main

```bash
git checkout main
git merge feature/docker
```

### Passo 6.5: Push para o GitHub

```bash
git push origin main
```

### Passo 6.6: Verificar no GitHub

Acesse o repositório no GitHub e confirme que o `aula-01/app/Dockerfile` e `aula-01/app/.dockerignore` estão presentes.

### Passo 6.7: O teste definitivo — clone e rode

Simule um novo desenvolvedor entrando no time:

```bash
cd ..
mkdir teste-novo-dev
cd teste-novo-dev
git clone https://github.com/SEU-USUARIO/unifaat-devops-portfolio.git
cd unifaat-devops-portfolio/aula-01/app
docker build -t portfolio-aula01:1.0 .
docker run -d --rm --name teste-final -p 3000:3000 portfolio-aula01:1.0
curl http://localhost:3000
```

**Resultado esperado:** A API responde! Um novo desenvolvedor pode ir de zero a aplicação rodando com apenas 3 comandos: `clone`, `build`, `run`.

```bash
docker stop teste-final
cd ../../..
```

✅ **Checkpoint 6:** Dockerfile versionado no Git. Qualquer pessoa que clonar o repo pode construir e rodar a aplicação de forma idêntica.

---

## Troubleshooting — Problemas Comuns

### ❌ Erro: `Cannot connect to the Docker daemon`

**Causa:** O Docker Engine não está rodando.

**Solução:**
- **Windows/macOS:** Inicie o Docker Desktop (clique no ícone)
- **Linux:** `sudo systemctl start docker`

### ❌ Erro: `port is already allocated`

**Causa:** Outro processo ou container já está usando a porta 3000.

**Solução:**
```bash
# Ver o que está usando a porta
docker ps

# Opção 1: Parar o container que está usando
docker stop <nome-do-container>

# Opção 2: Usar outra porta no mapeamento
docker run -d --name portfolio-container -p 3001:3000 portfolio-aula01:1.0
# Acesse via http://localhost:3001
```

### ❌ Erro: `COPY failed: file not found in build context`

**Causa:** O arquivo referenciado no `COPY` não existe ou está no `.dockerignore`.

**Solução:**
- Verifique se está executando `docker build` no diretório correto (onde está o Dockerfile)
- Verifique se o arquivo não está listado no `.dockerignore`
- Execute `ls` para confirmar que os arquivos existem

### ❌ Erro: `npm ERR! code ENOENT` durante build

**Causa:** O `package.json` não foi encontrado dentro do container.

**Solução:**
- Verifique se `package.json` existe na raiz do projeto
- Confirme que o `WORKDIR` está correto e o `COPY package*.json ./` está antes do `RUN npm install`

### ❌ Container inicia mas a API não responde

**Causa:** Erro na aplicação ou porta mapeada incorretamente.

**Solução:**
```bash
# Verificar logs para encontrar o erro
docker logs portfolio-container

# Verificar mapeamento de portas
docker port portfolio-container

# Se necessário, entrar no container para debugar
docker exec -it portfolio-container sh
```

### ❌ Build muito lento após mudanças no código

**Causa:** Cache de camadas sendo invalidado desnecessariamente.

**Solução:** Certifique-se de que a ordem no Dockerfile está correta:
1. `COPY package*.json ./` (primeiro!)
2. `RUN npm install`
3. `COPY . .` (por último!)

Se `COPY . .` vier antes de `npm install`, qualquer mudança no código invalidará o cache de todas as camadas subsequentes.

### ❌ Erro: `no space left on device`

**Causa:** Imagens e containers antigos estão ocupando disco.

**Solução:**
```bash
# Remover containers parados
docker container prune

# Remover imagens não utilizadas
docker image prune

# Limpeza completa (CUIDADO: remove tudo não utilizado)
docker system prune
```

---

## Validação Final — Parte 2

Ao concluir este laboratório, você deve ter:

- [ ] Docker instalado e funcional (verificado com `hello-world`)
- [ ] Imagem `node:20-alpine` baixada e testada
- [ ] Arquivo `aula-01/app/Dockerfile` criado com otimização de camadas
- [ ] Arquivo `aula-01/app/.dockerignore` configurado corretamente
- [ ] Imagem `portfolio-aula01:1.0` construída com sucesso
- [ ] Container rodando e API respondendo na porta 3000
- [ ] Experiência com logs, exec, stop, start e rm
- [ ] Container rodando com variáveis de ambiente customizadas
- [ ] Dockerfile e .dockerignore versionados no Git e publicados no GitHub
- [ ] Teste de clone + build + run simulando um novo desenvolvedor

---

*Parabéns! O seu portfólio DevOps agora tem código versionado com Git E aplicação containerizada com Docker. Qualquer desenvolvedor pode ir de zero a "aplicação rodando" em 3 comandos. Na próxima aula, vamos evoluir para Docker Compose — orquestrando múltiplos containers (API + banco de dados) para montar o ambiente de desenvolvimento local completo.*
