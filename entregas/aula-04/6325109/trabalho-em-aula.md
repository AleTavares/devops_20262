# Trabalho em Aula — Aula 04: Arquitetura de Rede da TechNova

**Aluno:** Carina Gonçalves dos Santos Dalpino
**RA:** 6325109
**Data:** 03/09/2026

---

## Parte 1 — Desenhar a Arquitetura

### Diagrama da rede

```
                          Internet
                              │
                    ┌─────────▼─────────┐
                    │  Internet Gateway  │
                    │    (technova-igw)  │
                    └─────────┬─────────┘
                              │
         ┌────────────────────▼────────────────────┐
         │              VPC 10.0.0.0/16             │
         │              (technova-vpc)              │
         │                                          │
         │   us-east-1a            us-east-1b       │
         │  ┌────────────┐        ┌────────────┐    │
         │  │ Pub Subnet │        │ Pub Subnet │    │
         │  │ 10.0.1.0/24│        │ 10.0.3.0/24│   │
         │  │  [EC2 API] │        │ [futuro ALB]│   │
         │  │  SG: 22,   │        │            │    │
         │  │  3000 open │        │            │    │
         │  └────────────┘        └────────────┘    │
         │  ┌────────────┐        ┌────────────┐    │
         │  │ Priv Subnet│        │ Priv Subnet│    │
         │  │ 10.0.2.0/24│        │ 10.0.4.0/24│   │
         │  │ [futuro RDS│        │ [futuro RDS│    │
         │  │  SG: 5432  │        │  replica]  │    │
         │  │  VPC only] │        │            │    │
         │  └────────────┘        └────────────┘    │
         │                                          │
         │  Route Table Pública: 0.0.0.0/0 → IGW   │
         │  Route Table Privada: apenas rota local  │
         └──────────────────────────────────────────┘
```

### Respostas às questões-guia

- **Bloco CIDR escolhido e justificativa:** `10.0.0.0/16` — oferece 65.536 endereços IP, espaço suficiente para dividir em múltiplas subnets em diferentes AZs sem desperdício. O range `10.x.x.x` é privado (RFC 1918) e não conflita com a internet pública.

- **Por que a API fica na subnet pública:** A API Node.js precisa receber requisições HTTP externas (porta 3000) diretamente da internet. Para isso, a instância EC2 precisa de um IP público e de uma rota até o Internet Gateway — o que só existe na subnet pública.

- **Por que o banco fica na subnet privada:** O banco de dados nunca deve ser acessível diretamente pela internet. Ele só precisa se comunicar com a API (dentro da própria VPC). Colocá-lo em subnet privada garante que nenhuma rota externa chegue até ele — mesmo que alguém tente acessar o IP, não há caminho de rede para isso.

- **Como o banco acessa a internet (atualizações):** Precisaria de um **NAT Gateway** na subnet pública. A subnet privada teria uma rota `0.0.0.0/0 → NAT Gateway`, permitindo tráfego de **saída** (para baixar patches) sem expor nenhuma porta de **entrada**. No lab não usamos NAT Gateway para evitar custos (~$32/mês).

- **Porta SSH aberta para 0.0.0.0/0 — adequado ou não:** Não é adequado para produção. Deixar a porta 22 aberta para qualquer IP expõe a instância a ataques de força bruta. O correto seria restringir a um IP específico (`seu-ip/32`), usar um Bastion Host em subnet pública como único ponto de entrada SSH, ou substituir completamente por AWS Systems Manager Session Manager (sem porta 22 aberta).

- **O que acontece sem rota para o IGW:** A subnet pública deixa de ser "pública" na prática. As instâncias até podem ter IP público, mas o tráfego da internet não tem caminho para chegar até elas — e elas também não conseguem acessar a internet. A API ficaria inacessível.

---

## Parte 2 — Discussão: Público vs Privado

### Classificação dos componentes

| Componente | Público ou Privado | Justificativa |
|---|---|---|
| API (Node.js) | **Público** | Precisa receber requisições HTTP da internet na porta 3000 |
| Banco (PostgreSQL) | **Privado** | Deve ser acessível apenas pela API (tráfego interno da VPC), nunca exposto à internet |
| Cache (Redis) | **Privado** | Dado sensível, acesso interno apenas entre os serviços da aplicação |
| Load Balancer | **Público** | É o ponto de entrada do tráfego externo — distribui para instâncias EC2 privadas |
| Worker (background jobs) | **Privado** | Não recebe tráfego externo, apenas consome filas/eventos internos |
| Bastion Host | **Público** | É a porta de entrada segura e controlada para acessar recursos em subnets privadas via SSH |
