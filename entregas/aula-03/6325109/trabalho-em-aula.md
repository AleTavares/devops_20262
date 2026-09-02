# Trabalho em Aula — Aula 03: Terraform e Segurança AWS (IAM)

**Aluno:** Carina Gonçalves dos Santos Dalpino  
**RA:** 6325109  
**Data:** 18/08/2026

---

## Parte 1 — Análise do Problema de Infraestrutura Manual

### Problemas identificados no cenário da TechNova

| # | Problema | Classificação |
|---|---|---|
| 1 | Infraestrutura criada pelo console sem documentação — impossível reproduzir | 🔴 Crítico |
| 2 | Toda a equipe usando credenciais root — se vazar, acesso total à conta | 🔴 Crítico |
| 3 | Sem histórico de alterações — não se sabe quem configurou o quê | 🔴 Crítico |
| 4 | Criar staging igual a produção requer repetir dezenas de passos manuais | 🟡 Moderado |
| 5 | Sem auditoria — compliance e governança comprometidos | 🟡 Moderado |

### Como o Terraform resolve cada problema

| Problema | Como o Terraform resolve |
|---|---|
| Infraestrutura sem documentação | Arquivos `.tf` são a documentação — descrevem exatamente o que foi criado |
| Sem histórico de alterações | Arquivos `.tf` versionados no Git — cada mudança tem commit, autor e data |
| Não reproduzível | O mesmo código gera a mesma infraestrutura em qualquer ambiente |
| Processo manual demorado | `terraform apply` cria todos os recursos automaticamente |
| Sem auditoria | Pull Requests para infraestrutura = revisão antes de aplicar mudanças |

---

## Parte 2 — IAM e Segurança

### Componentes IAM e suas funções

| Componente | Para que serve | Exemplo no projeto TechNova |
|---|---|---|
| **User** | Representa uma pessoa ou aplicação | `technova-dev-joao` |
| **Group** | Agrupa usuários com mesmas permissões | `technova-developers` |
| **Role** | Identidade assumível por serviços AWS | `technova-ec2-s3-role` (assumido pelo EC2) |
| **Policy** | Documento JSON que define Allow/Deny | `developer-s3-policy` |

### Aplicação do Menor Privilégio

| Grupo | Permissões concedidas | Justificativa |
|---|---|---|
| `developers` | S3 read/write no bucket `technova-*`, CloudWatch read | Precisam ler/escrever código e ver logs da aplicação |
| `devops` | S3 completo, EC2 read, IAM roles | Precisam gerenciar infraestrutura e fazer deploys |
| `readonly` | ReadOnlyAccess (somente leitura) | Acesso para auditoria sem risco de alterações |

### Por que Roles são melhores que Access Keys para serviços AWS?

- **Access Keys** são credenciais fixas que ficam no código ou em variáveis de ambiente. Se o servidor for comprometido, o atacante tem acesso permanente até as credenciais serem revogadas manualmente.

- **Roles** fornecem credenciais temporárias que rotacionam automaticamente a cada hora. Se o servidor for comprometido, as credenciais expiram sozinhas. Não há segredo para vazar.

### Discussão — Credenciais Root

Usar root para operações do dia a dia é uma das piores práticas de segurança na AWS porque:

1. A conta root tem acesso irrestrito a **tudo** — incluindo fechar a conta, alterar faturamento e remover MFA
2. Não é possível restringir o que root pode fazer via policies
3. Se comprometida, o impacto é total e irreversível
4. Não é possível auditar ações root com o mesmo nível de detalhe que IAM users

A solução correta é criar IAM users individuais com apenas as permissões necessárias, ativar MFA na conta root, e nunca usar root para operações rotineiras.

---

## Parte 3 — Reflexão sobre IaC

### Comparação: Console AWS vs Terraform

| Aspecto | Console AWS (manual) | Terraform (IaC) |
|---|---|---|
| Documentação | Nenhuma automática | O código é a documentação |
| Reproduzível | Não — depende de memória | Sim — mesmo código, mesmo resultado |
| Versionável | Não | Sim — Git |
| Auditável | Difícil | Sim — PR + histórico de commits |
| Velocidade (primeira vez) | Rápido para 1 recurso | Mais lento (escrever código) |
| Velocidade (repetir) | Lento — refaz tudo na mão | Rápido — `terraform apply` |
| Risco de erro | Alto — clique errado | Baixo — `plan` antes de `apply` |

### O que aprendi sobre Terraform nesta aula

- O fluxo `init → plan → apply → destroy` garante previsibilidade — nunca aplico sem revisar o plan
- O arquivo `terraform.tfstate` é a memória do Terraform e nunca deve ir para o Git
- HCL é mais legível que JSON para descrever infraestrutura
- `for_each` permite criar múltiplos recursos similares sem repetir código
- Tags em todos os recursos facilitam auditoria e controle de custos
