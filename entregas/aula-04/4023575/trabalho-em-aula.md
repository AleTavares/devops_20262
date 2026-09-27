# Trabalho em Aula — Aula 04: Arquitetura de Rede da TechNova
**Aluno:** Emilly Santos
**Data:** 12/09/2026

## Parte 1 — Desenhar a Arquitetura

### Diagrama da rede

text
┌───────────────────────────────────────────────────────────────────────────┐
│  VPC: 10.0.0.0/16                                                         │
│                                                                           │
│  ┌── Subnet Pública (10.0.1.0/24) ──────┐  ┌── Subnet Privada (10.0.2.0/24) ────┐ │
│  │ AZ: us-east-1a                     │  │ AZ: us-east-1a                    │ │
│  │                                    │  │                                   │ │
│  │ Recursos:                          │  │ Recursos:                         │ │
│  │ - EC2 (API Node.js)                │  │ - RDS (PostgreSQL)                │ │
│  │ - Bastion Host (opcional)          │  │                                   │ │
│  │                                    │  │ SG Inbound (SG-RDS):              │ │
│  │ SG Inbound (SG-EC2):               │  │ - Porta 5432 origem: SG-EC2       │ │
│  │ - Porta 3000 de 0.0.0.0/0          │  └───────────────────────────────────┘ │
│  │ - Porta 22 de IP-ADMIN-MY-IP       │                                        │
│  └────────────────────────────────────┘                                        │
│                                                                           │
│  Internet Gateway (IGW): Conectado à VPC                                  │
│                                                                           │
│  Route Table Pública: 0.0.0.0/0 → Internet Gateway                        │
│  Route Table Privada: 10.0.0.0/16 (Apenas tráfego local da VPC)           │
└───────────────────────────────────────────────────────────────────────────┘


### Respostas às questões-guia
- **Bloco CIDR escolhido e justificativa:** `10.0.0.0/16` (oferece 65.536 endereços IP privados, espaço suficiente para segmentação de subnets e crescimento futuro da TechNova).
- **Por que a API fica na subnet pública:** Porque necessita receber requisições HTTP/HTTPS diretas de clientes externos vindas da internet.
- **Por que o banco fica na subnet privada:** Para proteção dos dados. Não deve possuir IP público nem rotas diretas para a internet, sendo acessível estritamente pelos servidores da aplicação.
- **Como o banco acessa a internet (atualizações):** Através de um **NAT Gateway** localizado na subnet pública, com rotas de saída para a internet configuradas na tabela de roteamento privada.
- **Porta SSH aberta para 0.0.0.0/0 — adequado ou não:** **Inadequado**. Abrir a porta 22 para qualquer IP expõe o servidor a ataques de força bruta. Deve ser restrita ao IP público dos administradores ou acessada via Bastion Host / SSM Session Manager.
- **O que acontece sem rota para o IGW:** A subnet pública perde conectividade externa; instâncias alocadas nela não conseguem receber tráfego da internet nem enviar respostas.

---

## Parte 2 — Discussão: Público vs Privado

### Classificação dos componentes

| Componente | Público ou Privado | Justificativa |
|---|---|---|
| API (Node.js) | Pública | Ponto de entrada das requisições externas dos usuários/clientes. |
| Banco (PostgreSQL) | Privada | Contém dados sensíveis; deve ser acessado exclusivamente pela API interna. |
| Cache (Redis) | Privada | Armazena sessões e cache de dados de alta sensibilidade; acesso estritamente interno. |
| Load Balancer | Público | Distribui o tráfego de entrada da internet entre as instâncias de API públicas/privadas. |
| Worker (background jobs) | Privada | Processa filas assíncronas internas e não precisa receber requisições externas. |
| Bastion Host | Público | Ponto de entrada seguro e auditado para que administradores acessem a rede privada via SSH. |
