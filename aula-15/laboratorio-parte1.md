# Aula 15 — Laboratório Parte 1: Preparação Final e Ensaio da Demo

## 📋 Informações

| Item | Descrição |
|------|-----------|
| **Tipo** | Preparação prática |
| **Objetivo** | Verificar portfólio completo, testar demo, preparar apresentação |
| **Pré-requisito** | TA.md concluído |

---

## 🎬 Contexto Narrativo

> Falta pouco para a reunião com a diretoria. Você tem esse tempo para fazer o último check em
> todos os sistemas, rodar um ensaio geral da sua demo e garantir que tudo está no ar. Esse é o
> momento de verificar, não de implementar coisas novas.

---

## 🎯 Objetivo

Este "laboratório" é, na verdade, o tempo de preparação final. Use-o para:
1. Verificar que o portfólio está completo
2. Rodar a demo uma última vez
3. Resolver qualquer problema de última hora
4. Preparar o ambiente para a apresentação

---

## Etapa 1: Verificação do Portfólio

### Checklist de Completude

Execute na raiz do seu repositório `unifaat-devops-portfolio`. A orquestração em produção usa **EC2/ALB via Terraform** no Learner Lab (sem plataformas de orquestração de containers), então o checklist reflete as etapas reais do curso:

```bash
echo "=== Verificando estrutura do portfólio ==="
echo ""

# README principal
if [ -f "README.md" ]; then
    lines=$(wc -l < README.md)
    echo "✅ README.md existe ($lines linhas)"
else
    echo "❌ README.md não encontrado!"
fi

echo ""
echo "=== Verificando etapas do curso ==="

# Etapas reais do curso (ajuste os nomes às pastas que você usou)
for dir in git-docker docker-compose ia-copiloto terraform-aws \
           terraform-state-modules ci-github-actions registry-ecr \
           cd-gitops deploy-blue-green-canary rollback-aiops projeto-integrador; do
    if [ -d "$dir" ]; then
        files=$(ls "$dir" | wc -l)
        echo "✅ $dir/ ($files arquivos)"
    else
        echo "⚠️  $dir/ não encontrado (confira o nome usado no seu portfólio)"
    fi
done

echo ""
echo "=== Verificando componentes essenciais ==="

# Pipeline
if [ -d ".github/workflows" ]; then
    workflows=$(ls .github/workflows/*.yml 2>/dev/null | wc -l)
    echo "✅ .github/workflows/ ($workflows workflows)"
else
    echo "❌ .github/workflows/ não encontrado"
fi

# Docker
if [ -f "Dockerfile" ] || [ -f "app-technova/Dockerfile" ]; then
    echo "✅ Dockerfile encontrado"
else
    echo "❌ Dockerfile não encontrado"
fi

# Docker Compose
if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
    echo "✅ docker-compose.yml encontrado"
else
    echo "❌ docker-compose.yml não encontrado"
fi

# IaC
if [ -d "infra" ] || [ -f "main.tf" ]; then
    echo "✅ Código de infraestrutura (Terraform) encontrado"
else
    echo "⚠️  Pasta infra/ não encontrada (opcional se usou outro diretório)"
fi
```

### Corrigir Lacunas

Se encontrou ❌ em algum item:

| Problema | Solução rápida (não ideal, mas resolve) |
|----------|------------------------------------------|
| Pasta de etapa faltando | `mkdir etapa-X && echo "# Etapa X - [tema]" > etapa-X/README.md` |
| README incompleto | Adicione pelo menos: título, descrição, stack, como rodar |
| Workflow ausente | Copie um workflow básico de CI que pelo menos faz lint |
| Dockerfile ausente | Copie o Dockerfile que usou nas etapas anteriores |

**Atenção:** não crie conteúdo falso. É melhor ter uma pasta com um README honesto dizendo "não completei esta etapa" do que inventar conteúdo.

---

## Etapa 2: Ensaio da Demo ao Vivo

> **☁️ Learner Lab:** se a demo publica a imagem no **Amazon ECR** ou provisiona recursos
> (EC2, ALB, RDS, Bedrock), inicie a sessão do Lab, carregue as credenciais temporárias
> (`aws sts get-caller-identity` deve responder) e confirme a região `us-east-1` antes de
> começar. As credenciais do Lab **expiram por sessão**.

### 2.1 Testar Pipeline CI/CD

```bash
# Criar branch de teste
git checkout -b demo/ensaio-final

# Fazer alteração simples
echo "Ensaio $(date)" >> .demo-test

# Commit e push
git add .demo-test
git commit -m "test: ensaio da demo final"
git push origin demo/ensaio-final
```

**Verificar:**
- [ ] Push foi aceito?
- [ ] GitHub Actions disparou?
- [ ] CI passou (lint/test/build) e a imagem foi publicada no **Amazon ECR**?
- [ ] O workflow completou com sucesso? Anote quanto levou (para saber se cabe na sua janela de apresentação)

### 2.2 Testar Integração IA

```bash
# Se usa review automático de PR
gh pr create --title "test: ensaio demo IA" --body "Testando review automático"

# Verificar se o bot comentou
gh pr view --comments
```

**Verificar:**
- [ ] A IA fez review/comentário no PR?
- [ ] O comentário faz sentido?
- [ ] (Se usar o agente Bedrock) a invocação via credenciais da sessão do Lab respondeu?

### 2.3 Testar Aplicação Local

```bash
# Subir a aplicação
docker compose up -d

# Testar endpoint
curl -s http://localhost:3000/health | jq .

# Verificar logs (sem erros críticos)
docker compose logs --tail=20

# Parar
docker compose down
```

**Verificar:**
- [ ] Aplicação sobe sem erros?
- [ ] Health check retorna OK?
- [ ] Não há erros críticos nos logs?

---

## Etapa 3: Preparar o Ambiente de Apresentação

### Organizar Abas/Janelas

Prepare seu computador para a apresentação:

| Aba/Janela | Conteúdo | Finalidade |
|------------|----------|------------|
| Terminal 1 | Repositório local | Fazer commits e push |
| Terminal 2 | Docker / AWS CLI | Mostrar containers e o ECR |
| Navegador - Aba 1 | GitHub - repositório | Mostrar código e README |
| Navegador - Aba 2 | GitHub Actions | Mostrar o pipeline rodando |
| Navegador - Aba 3 | PR com review de IA | Mostrar a integração de IA |
| Navegador - Aba 4 | Console do Amazon ECR / app rodando | Mostrar a imagem publicada e o deploy |
| Slides (opcional) | Apresentação | Diagrama de arquitetura |

### Configurar Tela

```bash
# Aumentar a fonte do terminal (melhor visualização)
# No terminal: Ctrl + (ou Cmd +) para aumentar a fonte

# Limpar histórico do terminal
clear

# Prompt limpo com informação relevante
export PS1="\[\033[1;32m\]demo\[\033[0m\]:\[\033[1;34m\]\W\[\033[0m\]$ "
```

### Checklist Pré-Apresentação

- [ ] Bateria carregada (ou conectado na tomada)
- [ ] Internet funcionando
- [ ] Sessão do Learner Lab ativa e credenciais válidas (se a demo usar AWS)
- [ ] Todas as abas abertas
- [ ] Terminal com fonte legível
- [ ] GitHub logado
- [ ] Docker rodando (se necessário)
- [ ] Slides/roteiro acessível
- [ ] Cronômetro pronto (celular em modo silencioso)

---

## 🚨 Problemas Comuns e Soluções

| Problema | Solução |
|----------|---------|
| GitHub Actions não dispara | Verificar se o workflow YAML está correto e na branch certa |
| Docker não sobe | `docker compose down -v && docker compose up -d --build` |
| IA não fez review | Verificar se a Action de IA está configurada e com token válido |
| `ExpiredToken` ao usar o ECR/AWS | Sessão do Lab expirou — reabra o Lab e recarregue as credenciais |
| Internet instável | Ter screenshots/vídeo de backup prontos |
| Push rejeitado | `git pull --rebase origin main && git push` |

---

## 📦 Entregável da Etapa

Não há entregável formal nesta etapa. O objetivo é estar **100% preparado** para apresentar.

**Auto-check final:**
- "Minha demo funciona?" → Sim/Não
- "Tenho plano B?" → Sim/Não
- "Sei o que vou dizer em cada parte?" → Sim/Não
- "Estou dentro da minha janela de apresentação?" → Sim/Não

Se respondeu "Sim" a todas: você está pronto. 🎯

---

*Respire fundo. Você se preparou. Agora é só mostrar.* 🧘
