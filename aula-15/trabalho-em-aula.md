# Aula 15 — Trabalho em Aula

## Objetivo

Apresentar ao vivo o portfólio DevOps completo, demonstrando o pipeline end-to-end e a integração de IA, e participar da retrospectiva de encerramento avaliando os colegas com feedback construtivo.

**Formato:** Apresentação oral + demonstração ao vivo + avaliação por pares

---

## 🎬 Contexto Narrativo

> A sala de reunião principal da TechNova está lotada. O CEO abre a sessão:
> "Há 15 encontros, estávamos em crise. Deploys falhavam, clientes reclamavam, a equipe estava
> exausta. Vocês foram contratados para mudar isso. Hoje, quero ver o resultado. Mostrem o que
> construíram."

---

## Parte 1 — Apresentação do Portfólio

### Formato

Cada aluno/grupo apresenta ao vivo, com demo. A ordem é definida por sorteio no início da aula.

| Segmento | O que apresentar |
|----------|-----------------|
| **Arquitetura** | Visão geral do sistema, diagrama, tecnologias (AWS no Learner Lab) |
| **Demo Pipeline** | Push → CI (lint/test/build) → push da imagem no **Amazon ECR** → Deploy |
| **Demo IA** | Review automático de PR, geração/validação de IaC, ou agente Bedrock |
| **Lições e Evolução** | Antes/depois (Aula 01 → 15), desafios, aprendizados |
| **Perguntas** | Turma + professor |

> **☁️ Learner Lab:** se a demo usa AWS (ECR, EC2, ALB, Bedrock), confirme a sessão do Lab
> ativa e as credenciais temporárias válidas (`us-east-1`) antes de apresentar. Tenha um
> plano B (vídeo/screenshots).

### Atividade — O Que Deve Ser Demonstrado

**1. Arquitetura (obrigatório).** Mostre um diagrama (pode ser simples) com repositório GitHub, pipeline CI/CD, containers Docker, infraestrutura (Terraform no Learner Lab) e observabilidade (se implementada):

```
[Dev Push] → [GitHub Actions CI] → [Docker Build] → [Push no Amazon ECR] → [Deploy] → [App Running]
                    ↓                                                                       ↓
              [Testes Auto]                                                          [Observabilidade]
                    ↓
              [IA Review PR]
```

**2. Demo do Pipeline (obrigatório).** Demonstre o fluxo completo:

```bash
# Passo 1: Fazer uma alteração
echo "Apresentacao final - $(date)" >> CHANGELOG.md

# Passo 2: Commit e push
git add CHANGELOG.md
git commit -m "feat: atualizacao para apresentacao final"
git push origin main

# Passo 3: Mostrar o CI executando (GitHub Actions)
# Passo 4: Mostrar o resultado — build passou? testes passaram?
#          imagem publicada no Amazon ECR? deploy ocorreu?
```

**3. Demo da Integração com IA (obrigatório).** Demonstre pelo menos uma:
- **Opção A — Review de PR com IA:** criar branch/PR e mostrar o review automático
- **Opção B — IaC com IA:** mostrar o prompt, o código gerado e a validação (`terraform validate`)
- **Opção C — Agente DevOps (Bedrock):** análise de PR, detecção de drift ou geração de runbook

**4. Disaster Recovery (bônus).** Se implementou: rollback de deploy, recovery de container, health check + restart automático.

**5. Lições Aprendidas (obrigatório).** Responda em poucos minutos: estado na Aula 01, o que mudou, maior desafio técnico, o que faria diferente e próximo passo na jornada DevOps.

---

## Parte 2 — Avaliação por Pares

Cada aluno avalia 3 colegas usando este formulário simplificado:

| Apresentador | Pipeline Funciona? | Portfólio Completo? | Demo Clara? | Nota (1-5) | Feedback |
|--------------|--------------------|---------------------|-------------|------------|----------|
| Nome 1 | Sim/Parcial/Não | Sim/Parcial/Não | Sim/Parcial/Não | __ | ________ |
| Nome 2 | Sim/Parcial/Não | Sim/Parcial/Não | Sim/Parcial/Não | __ | ________ |
| Nome 3 | Sim/Parcial/Não | Sim/Parcial/Não | Sim/Parcial/Não | __ | ________ |

**Regras para feedback:**
- Seja específico: "Gostei de como você mostrou o rollback" > "Foi bom"
- Seja construtivo: "Poderia ter mostrado os logs do CI" > "Faltou coisa"
- Seja respeitoso: lembre que todos estão aprendendo

---

## Critérios de Avaliação

| Critério | Peso |
|----------|:----:|
| Clareza e organização da apresentação | 30% |
| Demonstração do pipeline end-to-end (CI → ECR → deploy) | 30% |
| Demonstração da integração de IA | 20% |
| Participação como avaliador (feedback construtivo aos colegas) | 20% |

---

## Entrega

### Onde entregar

No fork do repositório da disciplina, na pasta de entrega da aula:

```
entregas/aula-15/SEU-RA/trabalho-em-aula.md
```

### O que entregar

Um arquivo `trabalho-em-aula.md` com o registro da sua apresentação e das avaliações feitas em sala:

```markdown
# Trabalho em Aula — Aula 15: Apresentação Final

**Aluno:** [Seu nome completo]
**RA:** [Seu RA]
**Data:** [Data da aula]

## Minha Apresentação
- Link do portfólio (público): ...
- Resumo da arquitetura demonstrada: ...
- Pipeline demonstrado (CI → Amazon ECR → deploy): ...
- Integração de IA demonstrada (A/B/C): ...
- Maior lição da jornada Aula 01 → 15: ...

## Avaliação por Pares
| Apresentador | Pipeline | Portfólio | Demo Clara | Nota (1-5) | Feedback |
|--------------|----------|-----------|------------|------------|----------|
| Nome 1 | | | | | |
| Nome 2 | | | | | |
| Nome 3 | | | | | |
```

### Como entregar

- O arquivo pode ser adicionado no **mesmo PR** do TF ou em PR separado
- A entrega é **individual** — mesmo que a apresentação tenha sido em grupo
- O trabalho em aula vale **1 ponto na nota final** do semestre (contabilizado apenas ao final, com **todos** os trabalhos entregues)

---

*Boa apresentação! Mostrem do que são capazes.* 🎤
