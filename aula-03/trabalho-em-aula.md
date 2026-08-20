# Trabalho em Aula — Aula 03: Terraform e Segurança AWS

## Atividade em Grupo: "O que Pode Dar Errado na Nuvem?"

**Tempo estimado:** 30 minutos (durante o Bloco 1)
**Formato:** Grupos de 3-4 alunos

---

## Parte 1 — Análise de Riscos: Infraestrutura Manual (15 min)

### Contexto

O CTO da TechNova descreveu no TA como ele gastou 3 horas criando infraestrutura pelo Console AWS, sem documentação, e como o estagiário deletou um bucket por engano no dia seguinte.

### Tarefa

Em grupo, respondam:

**1. Listem pelo menos 5 riscos concretos** de gerenciar infraestrutura AWS manualmente (pelo Console):

Considere cenários como:
- O que acontece quando um membro da equipe sai da empresa?
- O que acontece quando precisam criar um ambiente idêntico (staging/produção)?
- O que acontece durante uma auditoria de compliance?
- O que acontece quando algo para de funcionar às 3h da manhã?
- O que acontece quando a equipe cresce de 4 para 20 pessoas?

**2. Para cada risco, indiquem como Terraform resolve o problema:**

| # | Risco (infraestrutura manual) | Como Terraform resolve |
|---|-------------------------------|------------------------|
| 1 | | |
| 2 | | |
| 3 | | |
| 4 | | |
| 5 | | |

---

## Parte 2 — Auditoria de Segurança: Design de IAM (15 min)

### Cenário

A SecureOps encontrou que TODOS na TechNova usam credenciais root. Vocês foram contratados para redesenhar o modelo de acesso. A equipe é:

| Pessoa | Cargo | O que precisa fazer |
|--------|-------|---------------------|
| Carlos Mendes | CTO | Visualizar billing, ler relatórios de custo |
| Juliana Santos | Dev Sênior | Ler/escrever S3, descrever EC2 |
| Rafael Oliveira | Platform Eng | Gerenciar EC2, S3, VPC, IAM (leitura) |
| Lucas | Estagiário | Apenas visualizar S3 (somente leitura) |
| API TechNova | Serviço (EC2) | Ler/escrever no bucket `technova-app-data` |

### Tarefa

**1. Desenhem a estrutura IAM no quadro/papel:**

- Quais **groups** vocês criariam?
- Quais **users** pertenceriam a cada group?
- Quais **policies** cada group receberia? (descreva as ações permitidas)
- Qual **role** criariam para o serviço? (com trust policy)

**2. Preencham o diagrama:**

```
AWS Account Root (NUNCA usar diretamente)
│
├── Group: ________________
│   ├── Users: ________________
│   └── Policy: ________________ (ações: _______________)
│
├── Group: ________________
│   ├── Users: ________________
│   └── Policy: ________________ (ações: _______________)
│
├── Group: ________________
│   ├── Users: ________________
│   └── Policy: ________________ (ações: _______________)
│
└── Role: ________________
    ├── Trust Policy: Serviço _______ pode assumir
    └── Permissions: ________________ (ações: _______________)
```

**3. Identifiquem pelo menos 2 cenários onde o princípio do menor privilégio seria violado se vocês usassem AWS Managed Policies (como `AmazonS3FullAccess`) em vez de custom policies.**

---

## Critérios de Avaliação

| Critério | Peso |
|----------|------|
| Identificou riscos reais e relevantes da infraestrutura manual | 25% |
| Explicou como Terraform resolve cada risco identificado | 25% |
| Estrutura IAM com separação clara de responsabilidades | 25% |
| Aplicação correta do princípio do menor privilégio | 25% |

---

## Apresentação

Cada grupo terá **3 minutos** para apresentar:
1. O risco mais crítico que identificaram (Parte 1)
2. A estrutura IAM proposta (Parte 2)
3. Um exemplo de como menor privilégio protege contra um cenário de ataque

---

## Entrega

### Onde entregar

No fork do repositório da disciplina, na pasta de entrega da aula:

```
entregas/aula-03/SEU-RA/trabalho-em-aula.md
```

### O que entregar

Um arquivo `trabalho-em-aula.md` com as respostas das atividades realizadas em sala:

```markdown
# Trabalho em Aula — Aula 03: Terraform e Segurança AWS

**Aluno:** [Seu nome completo]  
**RA:** [Seu RA]  
**Data:** [Data da aula]

## Parte 1 — Análise de Riscos: Infraestrutura Manual

### Riscos e soluções com Terraform

| # | Risco (infraestrutura manual) | Como Terraform resolve |
|---|-------------------------------|------------------------|
| 1 | | |
| 2 | | |
| 3 | | |
| 4 | | |
| 5 | | |

## Parte 2 — Auditoria de Segurança: Design de IAM

### Estrutura IAM proposta

[Preencha o diagrama de groups, users, policies e roles]

### Violações de menor privilégio com Managed Policies

1. ...
2. ...
```

### Como entregar

- O arquivo pode ser adicionado no **mesmo PR** do TF ou em PR separado
- A entrega é **individual** — mesmo que a atividade tenha sido em grupo
- O trabalho em aula vale **1 ponto na nota final** do semestre (contabilizado apenas ao final, com **todos** os trabalhos entregues)

---

*Esta atividade será referência para os laboratórios: vocês implementarão com Terraform a estrutura IAM que desenharam aqui.*
