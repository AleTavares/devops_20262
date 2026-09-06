# Trabalho em Aula — Aula 04: Arquitetura de Rede da TechNova

**Aluno:** Gabriel Reis Cunha
**RA:** 6325149
**Data:** 03/09/2026

## Parte 1 — Desenhar a Arquitetura

### Diagrama da rede

```
┌────────────────────────────────────────────────────────────────┐
│  VPC: 10.0.0.0/16   (65.536 IPs — espaço amplo p/ crescimento)   │
│                                                                  │
│  ┌─── Subnet Pública ──────────┐  ┌─── Subnet Privada ────────┐ │
│  │  CIDR: 10.0.1.0/24           │  │  CIDR: 10.0.2.0/24         │ │
│  │                              │  │                            │ │
│  │  Recursos:                   │  │  Recursos:                 │ │
│  │  - EC2 API Node.js (:3000)   │  │  - PostgreSQL (:5432)      │ │
│  │  - (futuro) Load Balancer    │  │  - (futuro) Redis/Workers  │ │
│  │                              │  │                            │ │
│  │  SG Inbound (api-sg):        │  │  SG Inbound (db-sg):       │ │
│  │  Porta 3000 de 0.0.0.0/0     │  │  Porta 5432 de 10.0.0.0/16 │ │
│  │  Porta 22   de <IP admin>    │  │  (somente de dentro da VPC)│ │
│  └──────────────────────────────┘  └────────────────────────────┘ │
│                                                                  │
│  Internet Gateway: [x] conectado à VPC                           │
│                                                                  │
│  Route Table Pública: 0.0.0.0/0 → Internet Gateway               │
│  Route Table Privada: (apenas rota local 10.0.0.0/16)            │
└────────────────────────────────────────────────────────────────┘
```

> Nota: no Laboratório usamos **Multi-AZ** (2 subnets públicas + 2 privadas em AZs
> diferentes: 10.0.1.0/24 e 10.0.3.0/24 públicas; 10.0.2.0/24 e 10.0.4.0/24 privadas),
> preparando a rede para alta disponibilidade e Load Balancer.

### Respostas às questões-guia

- **Bloco CIDR escolhido e justificativa:** `10.0.0.0/16` — faixa privada (RFC 1918), com 65.536 IPs. Dá espaço de sobra para segmentar em várias subnets `/24` (256 IPs cada) conforme o sistema cresce, sem risco de esgotar endereços.
- **Por que a API fica na subnet pública:** ela precisa receber requisições HTTP da internet (porta 3000), então precisa de IP público e rota para o Internet Gateway.
- **Por que o banco fica na subnet privada:** o PostgreSQL só deve ser acessado pela API, nunca pela internet. Sem rota para o IGW, ele fica inalcançável de fora — reduz drasticamente a superfície de ataque.
- **Como o banco acessa a internet (atualizações):** através de um **NAT Gateway** colocado na subnet pública. Ele permite tráfego de **saída** (baixar patches) sem permitir tráfego de **entrada** vindo da internet.
- **Porta SSH aberta para 0.0.0.0/0 — adequado ou não:** **não.** Expor a 22 para o mundo convida ataques de força bruta. O correto é liberar 22 apenas para o IP do administrador (ou via Bastion Host / SSM Session Manager).
- **O que acontece sem rota para o IGW:** a subnet deixa de ser realmente "pública" — mesmo com IP público, os recursos não conseguem se comunicar com a internet (nem entrada nem saída). A API ficaria inacessível.

## Parte 2 — Discussão: Público vs Privado

### Classificação dos componentes

| Componente | Público ou Privado | Justificativa |
|---|---|---|
| API (Node.js) | **Pública** | Precisa receber requisições HTTP diretamente da internet (porta 3000). |
| Banco (PostgreSQL) | **Privado** | Só a API deve acessá-lo; expô-lo à internet é risco crítico de vazamento de dados. |
| Cache (Redis) | **Privado** | Acesso exclusivamente interno e alta sensibilidade; nunca deve ser exposto. |
| Load Balancer | **Público** | É o ponto de entrada do tráfego externo; distribui as requisições para as instâncias. |
| Worker (background jobs) | **Privado** | Processa filas/tarefas internas; não recebe tráfego externo. |
| Bastion Host | **Público** | Porta de entrada SSH controlada para administrar recursos privados com segurança. |
