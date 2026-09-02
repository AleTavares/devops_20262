# Trabalho em Aula | Aula 04

## Atividade: Arquitetura de Rede da TechNova

**Formato:** Grupos de 3-4 alunos  
**Material:** Quadro branco, papel ou ferramenta digital (draw.io, Excalidraw)

---

## Contexto

A TechNova precisa migrar sua infraestrutura para a AWS. A equipe de Platform Engineering pediu que vocês desenhem a arquitetura de rede antes de começar a implementação com Terraform. O objetivo é pensar na segurança e organização ANTES de escrever código.

**Requisitos da TechNova:**
- API Node.js acessível pela internet (porta 3000)
- Banco de dados PostgreSQL inacessível diretamente da internet
- Acesso SSH apenas para administradores
- Isolamento entre componentes públicos e privados
- Espaço para crescimento futuro

---

## Parte 1 — Desenhar a Arquitetura (20 min)

### Instruções

Cada grupo deve desenhar no quadro branco (ou papel) a arquitetura completa de rede, incluindo:

1. **VPC** com bloco CIDR definido (justifiquem a escolha)
2. **Subnet pública** com CIDR (o que vai aqui?)
3. **Subnet privada** com CIDR (o que vai aqui?)
4. **Internet Gateway** — onde se conecta?
5. **Route Tables** — quais rotas para cada subnet?
6. **Security Groups** — quais portas abertas e para quem?

### Diagrama de Referência (mínimo esperado)

```
┌──────────────────────────────────────────────────────────┐
│  VPC: ___.___.___.___ / ___                              │
│                                                          │
│  ┌─── Subnet Pública ──────┐  ┌─── Subnet Privada ────┐ │
│  │  CIDR: ____________      │  │  CIDR: ____________    │ │
│  │                          │  │                        │ │
│  │  Recursos:               │  │  Recursos:             │ │
│  │  - _______________       │  │  - _______________     │ │
│  │  - _______________       │  │  - _______________     │ │
│  │                          │  │                        │ │
│  │  SG Inbound:             │  │  SG Inbound:           │ │
│  │  Porta ___ de ___        │  │  Porta ___ de ___      │ │
│  │  Porta ___ de ___        │  │  Porta ___ de ___      │ │
│  └──────────────────────────┘  └────────────────────────┘ │
│                                                          │
│  Internet Gateway: [  ] conectado à VPC                  │
│                                                          │
│  Route Table Pública: 0.0.0.0/0 → ___________           │
│  Route Table Privada: (apenas rota local)                │
└──────────────────────────────────────────────────────────┘
```

### Questões-guia para o grupo:

- Qual bloco CIDR usar na VPC? Por quê?
- Por que a API fica na subnet pública e o banco na privada?
- Se o banco precisa de atualizações, como acessaria a internet sem estar público?
- A porta SSH (22) deveria estar aberta para `0.0.0.0/0`? Por quê não?
- O que acontece se esquecermos de criar a rota para o IGW na subnet pública?

---

## Parte 2 — Discussão em Classe (10 min)

### Tópico de Debate: "O que vai na subnet pública vs privada?"

Cada grupo apresenta brevemente (2 min) seu diagrama. O professor conduz a discussão com as seguintes perguntas:

1. **API (Node.js)** — Pública ou privada? Por quê?
   - *Esperado:* Pública — precisa receber requisições HTTP da internet

2. **Banco de dados (PostgreSQL)** — Público ou privado? Por quê?
   - *Esperado:* Privada — apenas a API deve acessá-lo, não o mundo externo

3. **Cache (Redis)** — Público ou privado? Por quê?
   - *Esperado:* Privada — acesso interno apenas, alta sensibilidade

4. **Load Balancer** — Público ou privado? Por quê?
   - *Esperado:* Público — é o ponto de entrada do tráfego externo

5. **Worker de background jobs** — Público ou privado? Por quê?
   - *Esperado:* Privada — não precisa receber tráfego externo

6. **Bastion Host (SSH jump server)** — Público ou privado? Por quê?
   - *Esperado:* Público — é a porta de entrada segura para acessar recursos privados

### Perguntas provocativas:

- "Se tudo ficar na subnet pública, funciona?" (Sim, mas é inseguro — violaria o princípio do menor privilégio em rede)
- "E se o banco precisar baixar patches de segurança?" (Aí precisaria de NAT Gateway na subnet privada)
- "Quantas subnets públicas/privadas um sistema de produção deveria ter?" (Pelo menos 2 de cada — em AZs diferentes — para alta disponibilidade)

---

## Critérios de Avaliação

| Critério | Peso | Descrição |
|----------|------|-----------|
| Completude do diagrama | 30% | Todos os componentes presentes (VPC, subnets, IGW, RTs, SGs) |
| CIDRs corretos | 20% | Blocos CIDR válidos e coerentes (subnet dentro da VPC) |
| Justificativa de público/privado | 25% | Argumentação correta sobre o que vai em cada subnet |
| Security Groups adequados | 15% | Portas corretas e princípio do menor privilégio |
| Participação na discussão | 10% | Contribuição ativa nas perguntas do grupo |

---

## Resultado Esperado

Ao final da atividade, cada aluno deve ter:

1. ✅ Clareza sobre a arquitetura de rede que será implementada no Lab Parte 1
2. ✅ Entendimento da separação público/privado e suas razões
3. ✅ Noção dos componentes necessários (VPC, subnets, IGW, RT, SG)
4. ✅ Visão de como o EC2 (Lab Parte 2) se encaixa na rede

---

## Entrega

### Onde entregar

No fork do repositório da disciplina, na pasta de entrega da aula:

```
entregas/aula-04/SEU-RA/trabalho-em-aula.md
```

### O que entregar

Um arquivo `trabalho-em-aula.md` com as respostas das atividades realizadas em sala:

```markdown
# Trabalho em Aula — Aula 04: Arquitetura de Rede da TechNova

**Aluno:** [Seu nome completo]  
**RA:** [Seu RA]  
**Data:** [Data da aula]

## Parte 1 — Desenhar a Arquitetura

### Diagrama da rede

[Descreva ou cole o diagrama que seu grupo desenhou — VPC, subnets, IGW, RTs, SGs]

### Respostas às questões-guia

- Bloco CIDR escolhido e justificativa: ...
- Por que a API fica na subnet pública: ...
- Por que o banco fica na subnet privada: ...
- Como o banco acessa a internet (atualizações): ...
- Porta SSH aberta para 0.0.0.0/0 — adequado ou não: ...
- O que acontece sem rota para o IGW: ...

## Parte 2 — Discussão: Público vs Privado

### Classificação dos componentes

| Componente | Público ou Privado | Justificativa |
|---|---|---|
| API (Node.js) | | |
| Banco (PostgreSQL) | | |
| Cache (Redis) | | |
| Load Balancer | | |
| Worker (background jobs) | | |
| Bastion Host | | |
```

### Como entregar

- O arquivo pode ser adicionado no **mesmo PR** do TF ou em PR separado
- A entrega é **individual** — mesmo que a atividade tenha sido em grupo
- O trabalho em aula vale **1 ponto na nota final** do semestre (contabilizado apenas ao final, com **todos** os trabalhos entregues)

---

> **Próximo passo:** Implementar essa mesma arquitetura com Terraform no Laboratório Parte 1!
