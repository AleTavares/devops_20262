# Trabalho em Aula — Aula 01: Discussão Guiada

**Aluno:** Matheus Mantovani  
**RA:** 1120245  
**Data:** 24/08/2026

---

## Parte 1 — O Caos do Código

### 1. Problemas identificados (mínimo 4)

- **Ausência de fonte única de verdade:** existem múltiplos arquivos com nomes similares (`api_final_v3_FINAL_REAL.zip`) e nenhum mecanismo que indique qual é a versão correta de produção. Qualquer desenvolvedor pode escolher errado.
- **Sobrescrita silenciosa de trabalho:** ao copiar e modificar um arquivo sem isolamento, um desenvolvedor pode destruir o trabalho de outro sem perceber, como aconteceu com Marcos e Juliana.
- **Rastreabilidade zero:** é impossível saber quem fez qual alteração, quando e por quê. Não há histórico auditável de mudanças.
- **Impossibilidade de trabalho paralelo seguro:** dois desenvolvedores não conseguem trabalhar na mesma base de código ao mesmo tempo sem risco de conflito destrutivo.
- **Ausência de rollback confiável:** se um bug for introduzido, não há como voltar a um estado anterior conhecido e estável com segurança.

### 2. Impacto financeiro/operacional

Perder 3 dias de trabalho de uma desenvolvedora sênior representa custo direto de salário sem entrega, além do custo de oportunidade — funcionalidades que deveriam estar em produção gerando valor ficaram paradas. Somado a isso, o retrabalho ocupa tempo que poderia ser usado em novas features, afeta o moral da equipe e gera desconfiança nos processos internos da empresa.

### 3. Como o Git resolve

| Problema Identificado | Como o Git Resolve |
|---|---|
| Não saber qual versão é a correta | Existe uma branch `main` que é a fonte única de verdade; o `HEAD` sempre aponta para o estado atual estável |
| Sobrescrita do trabalho de outro desenvolvedor | Cada dev trabalha em sua própria branch; o merge só acontece após revisão, e conflitos são sinalizados explicitamente para resolução manual |
| Sem rastreabilidade de mudanças | Cada `commit` registra: o quê mudou, quem mudou, quando e por quê (mensagem). O `git log` e `git blame` expõem esse histórico completo |
| Trabalho paralelo inseguro | Branches isolam o desenvolvimento; dois devs podem trabalhar no mesmo projeto simultaneamente sem interferência |
| Sem rollback confiável | O `git revert` ou `git checkout <hash>` permite voltar a qualquer ponto do histórico com segurança e rastreabilidade |

### 4. Regras ao adotar Git

- **Ninguém commita diretamente na `main`** — todo desenvolvimento acontece em branches descritivas (`feature/`, `fix/`, `hotfix/`)
- **Mensagens de commit seguem Conventional Commits** (`feat:`, `fix:`, `docs:`, `chore:`) para manter o histórico legível
- **Commits atômicos:** cada commit representa uma única mudança lógica — facilita revisão e rollback
- **Pull Request obrigatório para merge na `main`** — pelo menos uma revisão de par antes de integrar código
- **Nunca versionar segredos:** `.env`, chaves privadas e `node_modules/` ficam no `.gitignore`

---

## Parte 2 — "Funciona na Minha Máquina"

### 5. Causa Raiz (3 categorias)

- **Versão do runtime diferente:** Juliana usa Node.js 20.11, Rafael tem Node.js 18.12, Marcos tem Node.js 20.9, servidor tem Node.js 18.17 — comportamentos e APIs disponíveis diferem entre versões
- **Dependências e bibliotecas do sistema operacional:** `bcrypt` compila código nativo e depende de `libssl`; versões diferentes do sistema operacional (macOS vs Ubuntu 22.04 vs Windows 11) têm versões diferentes dessas libs, causando incompatibilidades
- **Sistema operacional e arquitetura:** macOS, Ubuntu e Windows têm comportamentos distintos para path separators, encoding, permissões de arquivo e módulos nativos — o mesmo código pode se comportar de forma diferente em cada um

### 6. Requisitos da solução

- **Isolamento:** a aplicação deve rodar em um ambiente completamente isolado do sistema operacional do host, sem depender das versões instaladas localmente
- **Reprodutibilidade:** o ambiente deve ser definido em código (Dockerfile) e gerar o resultado exatamente igual em qualquer máquina que execute o build
- **Portabilidade:** a mesma imagem deve funcionar no laptop do desenvolvedor, no servidor de CI e em produção sem nenhuma alteração
- **Leveza:** deve ser possível subir e destruir ambientes em segundos, não minutos, e consumir poucos recursos para que múltiplos containers rodem no mesmo host

### 7. Container vs. VM

| Aspecto | VM | Container |
|---|---|---|
| Tempo de inicialização | Minutos (boot do SO completo) | Segundos (apenas o processo inicia) |
| Uso de disco | Gigabytes (SO guest + aplicação) | Megabytes (apenas aplicação + dependências) |
| Consumo de memória | Alto (SO guest consome RAM mesmo ocioso) | Mínimo (compartilha kernel do host) |
| Facilidade de versionamento | Baixa (imagens de VM são binárias e pesadas) | Alta (Dockerfile é texto, versionável no Git) |
| Densidade no servidor | ~10–20 VMs por host | ~100–1000 containers por host |

### 8. Git + Docker juntos

Com Git e Docker, um novo desenvolvedor na TechNova faria:

1. `git clone https://github.com/technova/api.git` — obtém o código e **toda a definição do ambiente** (Dockerfile)
2. `docker build -t technova-api:latest .` — constrói um ambiente idêntico ao de todos os outros devs, independente do SO local
3. `docker run -d -p 3000:3000 technova-api:latest` — sobe a aplicação em segundos

O resultado é sempre o mesmo: não importa se é macOS, Ubuntu ou Windows, a API roda dentro do container com Node.js 20-alpine, as mesmas versões de dependências e as mesmas configurações. O "funciona na minha máquina" deixa de existir porque **o ambiente está no repositório, junto com o código**.

---

## Parte 3 — Proposta para o CTO

"Carlos, propomos implementar **Git** para resolver o caos de versionamento e **Docker** para eliminar as inconsistências de ambiente. Com Git, a equipe terá uma fonte única de verdade, histórico auditável e capacidade de trabalhar em paralelo com segurança. Com Docker, qualquer desenvolvedor poderá rodar a API em segundos com o ambiente idêntico ao de produção, independente do sistema operacional. Com isso, a TechNova nunca mais perderá dias de trabalho por sobrescrita acidental de código, e o 'funciona na minha máquina' será apenas uma história do passado."
