# Entrega — Aula 01: Fundamentos de Git e Docker

**Aluno:** Weslley Lucas Souza Alves  
**RA:** 6325226  
**Data:** 2026-08-14

## Repositório

- URL: https://github.com/lucaskenway/technova-api.git

## Evidências

### 1. Aplicação Node.js criada com sucesso
- [x] Projeto `technova-api` inicializado
- [x] Arquivo `package.json` configurado
- [x] Servidor rodando na porta 3000

### 2. Dockerfile configurado
- [x] Base: `node:20-alpine`
- [x] Build multistage implementado
- [x] WORKDIR, COPY, RUN e EXPOSE configurados
- [x] Comando de inicialização: `node src/index.js`

### 3. Docker buildado e container rodando
- [x] Imagem `technova-api:latest` criada com sucesso
- [x] Container rodando e respondendo às requisições
- [x] Porta 3000 mapeada corretamente

### 4. Health Check funcionando
- [x] Endpoint GET `/health` implementado
- [x] Retorna status JSON com timestamp e versão
- [x] Resposta: `{"status": "healthy", "timestamp": "2026-08-14T16:36:12.604Z", "service": "technova-api", "version": "1.0.0"}`

### 5. Commits descritivos (Conventional Commits)
- [x] Commit: "Add Docker configuration"
- [x] Seguindo padrão: `[type]: [description]`
- [x] Git push realizado com sucesso

### 6. Evidências do fluxo do projeto

#### Captura 01 — Aplicação funcionando
![Captura 01 - Aplicação funcionando](./img/Captura%20de%20tela%202026-08-14%20171851.png)

*Aplicação acessível localmente e endpoint `/health` respondendo corretamente.*

#### Captura 02 — Comandos do Git
![Captura 02 - Comandos do Git](./img/Captura%20de%20tela%202026-08-14%20171950.png)

*Fluxo de versionamento com `git status`, `git add`, `git commit` e `git push`.*

#### Captura 03 — Build do Docker
![Captura 03 - Build do Docker](./img/Captura%20de%20tela%202026-08-14%20172007.png)

*Processo de build da imagem Docker e criação do container da aplicação.*

#### Captura 04 — Container em execução
![Captura 04 - Container em execução](./img/Captura%20de%20tela%202026-08-14%20172527.png)

*Resultado do `docker ps` e da aplicação rodando em ambiente containerizado.*

#### Captura 05 — Imagens Docker e acesso ao serviço
![Captura 05 - Imagens Docker e acesso ao serviço](./img/Captura%20de%20tela%202026-08-14%20172558.png)

*Imagem `technova-api:latest` lista e acesso ao serviço em execução na porta 3000.*

### 8. Evidências de Git (workflow de versionamento)

- [x] Repositório Git inicializado com `git init`
- [x] Configuração do Git concluída (`user.name`, `user.email`, `init.defaultBranch=main`)
- [x] Commit inicial realizado com mensagem descritiva (`docs: adiciona README inicial do projeto`)
- [x] Fluxo de versionamento documentado com `git status`, `git add`, `git commit` e `git log`
- [x] Branch de desenvolvimento criada e utilizada para o trabalho (`feature/health-check` ou equivalente)
- [x] Push realizado para o repositório remoto no GitHub

### 9. Checklist final

- [x] Laboratório Parte 1 — Git configurado e funcionando (`git --version`, `git config --list`, `git log --oneline`)
- [x] Laboratório Parte 1 — Repositório inicial criado com commit inicial do README
- [x] Laboratório Parte 2 — Docker instalado e funcionando (`docker --version`, `docker info`, `docker run hello-world`)
- [x] Laboratório Parte 2 — Imagem `node:20-alpine` baixada e container rodando corretamente
- [x] Prints organizados em ordem por laboratório e anexados na pasta `img/`

### 10. Respostas das questões de verificação

#### Questão 1
**Resposta correta:** B) No distribuído, cada desenvolvedor possui uma cópia completa do histórico do projeto.

Explicação: em Git, cada clone é um repositório completo com histórico local, permitindo trabalho paralelo, branches e commits sem depender de um servidor central para a maioria das ações.

#### Questão 2
**Resposta correta:** B) `git add` → `git commit` → `git push`

Explicação: primeiro adicionamos as alterações ao staging, depois salvamos o commit local e, por fim, enviamos para o repositório remoto com `git push`.

#### Questão 3
**Resposta correta:** C) Containers compartilham o kernel do host e isolam apenas o processo, enquanto VMs virtualizam um SO completo.

Explicação: containers são mais leves e rápidos porque não precisam virtualizar um sistema operacional inteiro; eles usam o kernel do host.

#### Questão 4
**Resposta correta:** B) Porque assim a camada de `npm install` é reaproveitada do cache quando apenas o código muda, acelerando o build.

Explicação: ao copiar primeiro `package.json` e instalar dependências antes do restante do código, o Docker consegue reutilizar camadas de cache quando o código muda, reduzindo tempo de build.

> Observação: as evidências principais do TF e do workflow Git já estão documentadas no arquivo, e os prints dos laboratórios foram organizados por ordem de execução para facilitar a revisão.