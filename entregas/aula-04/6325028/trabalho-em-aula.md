# Trabalho em Aula — Aula 04: Arquitetura de Rede da TechNova

**Aluno:** Denise Maider  
**RA:** 6325028  
**Data:** 10/09/2026

---

## Parte 1 — Desenhar a Arquitetura

### Diagrama da rede

```
┌──────────────────────────────────────────────────────────────────┐
│  VPC: 10.0.0.0 / 16                                              │
│                                                                  │
│  ┌─── Subnet Pública ──────────┐  ┌─── Subnet Privada ────────┐ │
│  │  CIDR: 10.0.1.0/24          │  │  CIDR: 10.0.2.0/24        │ │
│  │  AZ: us-east-1a             │  │  AZ: us-east-1a            │ │
│  │                             │  │                            │ │
│  │  Recursos:                  │  │  Recursos:                 │ │
│  │  - EC2 (API Node.js)        │  │  - RDS PostgreSQL          │ │
│  │  - Load Balancer (futuro)   │  │  - Cache Redis (futuro)    │ │
│  │  - Bastion Host (futuro)    │  │  - Workers (futuro)        │ │
│  │                             │  │                            │ │
│  │  SG Inbound:                │  │  SG Inbound:               │ │
│  │  Porta 22  de 0.0.0.0/0     │  │  Porta 5432 de 10.0.0.0/16│ │
│  │  Porta 3000 de 0.0.0.0/0   │  │                            │ │
│  └──────────────────────────── ┘  └────────────────────────────┘ │
│                                                                  │
│  Internet Gateway: [IGW] conectado à VPC                         │
│                                                                  │
│  Route Table Pública: 0.0.0.0/0 → IGW                           │
│  Route Table Privada: (apenas rota local 10.0.0.0/16)           │
└──────────────────────────────────────────────────────────────────┘
              ↕
          Internet
```

### Respostas às questões-guia

- **Bloco CIDR escolhido e justificativa:** `10.0.0.0/16` — oferece 65.536 endereços IP, espaço suficiente para crescimento. Usamos o range `10.x.x.x` (privado RFC 1918) para garantir que não há sobreposição com endereços públicos.

- **Por que a API fica na subnet pública:** A API Node.js precisa receber requisições HTTP da internet (porta 3000). Para isso, ela precisa estar em uma subnet que tenha rota para o Internet Gateway, ou seja, uma subnet pública. Sem isso, nenhum cliente externo conseguiria alcançar a API.

- **Por que o banco fica na subnet privada:** O banco de dados (PostgreSQL) nunca deve ser acessível diretamente da internet. Colocá-lo na subnet privada garante que apenas recursos dentro da própria VPC (como a API) conseguem se conectar a ele. Isso reduz drasticamente a superfície de ataque.

- **Como o banco acessa a internet (atualizações):** Para que o banco aplique patches de segurança sem ficar exposto, seria necessário um **NAT Gateway** na subnet pública. A subnet privada teria uma rota `0.0.0.0/0 → NAT Gateway`, permitindo tráfego de **saída** (outbound) para a internet, mas bloqueando qualquer tráfego de **entrada** (inbound) vindo de fora. O NAT Gateway tem custo (~$32/mês), por isso não foi usado neste lab.

- **Porta SSH aberta para 0.0.0.0/0 — adequado ou não:** **Não é adequado para produção.** Deixar a porta 22 aberta para qualquer IP expõe o servidor a ataques de força bruta e varreduras automatizadas. O correto seria restringir a `<meu-ip>/32` ou usar um Bastion Host com IP fixo. No lab, usamos `0.0.0.0/0` apenas por conveniência do ambiente educacional.

- **O que acontece sem rota para o IGW:** A subnet não tem como enviar ou receber tráfego da internet, mesmo que as instâncias tenham IP público. A subnet se comporta como "privada" — só tráfego interno à VPC funciona. A API ficaria inacessível de fora.

---

## Parte 2 — Discussão: Público vs Privado

### Classificação dos componentes

| Componente | Público ou Privado | Justificativa |
|---|---|---|
| API (Node.js) | **Público** | Precisa receber requisições HTTP da internet. É o ponto de entrada da aplicação para os usuários finais. |
| Banco (PostgreSQL) | **Privado** | Deve ser acessível apenas pela API. Expô-lo na internet seria um risco de segurança grave (dados sensíveis). |
| Cache (Redis) | **Privado** | Armazena dados em memória que só fazem sentido para a aplicação. Acesso interno apenas; exposição seria desperdício e risco. |
| Load Balancer | **Público** | É o ponto de entrada do tráfego externo — distribui as requisições entre múltiplas instâncias da API. Precisa de IP público. |
| Worker (background jobs) | **Privado** | Processa tarefas internas (filas, envio de e-mail, etc.). Não recebe tráfego da internet; não precisa de IP público. |
| Bastion Host | **Público** | É a "porta de entrada segura" para acessar recursos privados via SSH. Fica público para que administradores se conectem, mas com porta 22 restrita a IPs autorizados. |

---

## Observações Finais

A separação público/privado é um dos princípios mais importantes de segurança em nuvem. Ela implementa o conceito de **defesa em profundidade**: mesmo que um atacante comprometa a API (subnet pública), ainda teria que superar a barreira de rede para chegar ao banco (subnet privada). Essa arquitetura é o ponto de partida para qualquer sistema de produção na AWS.
