# Trabalho em Aula — Aula 04: Arquitetura de Rede da TechNova

**Aluno:** Carina Gonçalves dos Santos Dalpino  
**RA:** 6325109  
**Data:** 25/08/2026

---

## Parte 1 — Desenhar a Arquitetura

### Diagrama da rede

```
                          Internet
                              │
                    ┌─────────▼─────────┐
                    │  Internet Gateway  │
                    │   (technova-igw)   │
                    └─────────┬─────────┘
                              │
              ┌───────────────▼───────────────────────────┐
              │           VPC: 10.0.0.0/16                 │
              │            (technova-vpc)                  │
              │                                            │
              │  ┌─── Subnet Pública ──────────────────┐  │
              │  │  CIDR: 10.0.1.0/24 (us-east-1a)     │  │
              │  │  CIDR: 10.0.3.0/24 (us-east-1b)     │  │
              │  │                                      │  │
              │  │  Recursos:                           │  │
              │  │  - EC2 t3.micro (API Node.js :3000)  │  │
              │  │                                      │  │
              │  │  SG Inbound (technova-api-sg):        │  │
              │  │  Porta 22  de 0.0.0.0/0 (SSH)        │  │
              │  │  Porta 3000 de 0.0.0.0/0 (API)       │  │
              │  └──────────────────────────────────────┘  │
              │                                            │
              │  ┌─── Subnet Privada ──────────────────┐  │
              │  │  CIDR: 10.0.2.0/24 (us-east-1a)     │  │
              │  │  CIDR: 10.0.4.0/24 (us-east-1b)     │  │
              │  │                                      │  │
              │  │  Recursos:                           │  │
              │  │  - (futuro) RDS PostgreSQL           │  │
              │  │  - (futuro) Redis Cache              │  │
              │  │                                      │  │
              │  │  SG Inbound (technova-db-sg):         │  │
              │  │  Porta 5432 de 10.0.0.0/16 (VPC)    │  │
              │  └──────────────────────────────────────┘  │
              │                                            │
              │  Route Table Pública: 0.0.0.0/0 → IGW     │
              │  Route Table Privada: apenas rota local    │
              └────────────────────────────────────────────┘
```

### Respostas às questões-guia

- **Bloco CIDR escolhido e justificativa:** `10.0.0.0/16` — oferece 65.536 endereços IP, espaço suficiente para crescimento com múltiplas subnets em diferentes AZs sem sobreposição.

- **Por que a API fica na subnet pública:** A API precisa receber requisições HTTP da internet (porta 3000). Sem estar em subnet pública com rota para o IGW, o tráfego externo não chegaria até ela.

- **Por que o banco fica na subnet privada:** O banco de dados nunca deve ser acessível diretamente da internet — apenas a API deve se comunicar com ele. Colocá-lo em subnet privada garante que mesmo que alguém descubra o IP, não conseguirá acessar sem estar dentro da VPC.

- **Como o banco acessa a internet (atualizações):** Seria necessário um NAT Gateway na subnet pública, com uma rota na Route Table privada apontando para ele. Assim o banco pode fazer conexões de saída (downloads de patches) sem expor uma rota de entrada da internet.

- **Porta SSH aberta para 0.0.0.0/0 — adequado ou não:** Não é ideal em produção — o correto seria restringir ao IP do administrador (`meu-ip/32`). Para fins de laboratório foi mantida aberta, mas em ambiente real usaríamos um Bastion Host ou VPN para acesso SSH.

- **O que acontece sem rota para o IGW:** A subnet pública perde a conectividade com a internet. O EC2 não consegue receber requisições externas nem fazer chamadas de saída, tornando a API inacessível.

---

## Parte 2 — Discussão: Público vs Privado

### Classificação dos componentes

| Componente | Público ou Privado | Justificativa |
|---|---|---|
| API (Node.js) | **Público** | Precisa receber requisições HTTP da internet |
| Banco (PostgreSQL) | **Privado** | Apenas a API deve acessá-lo, nunca a internet |
| Cache (Redis) | **Privado** | Acesso interno apenas, contém dados sensíveis de sessão |
| Load Balancer | **Público** | É o ponto de entrada do tráfego externo, distribui para EC2s privados |
| Worker (background jobs) | **Privado** | Não precisa receber tráfego externo, só processa filas internas |
| Bastion Host | **Público** | Porta de entrada segura para acessar recursos privados via SSH |
