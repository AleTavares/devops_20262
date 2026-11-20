# Trabalho em Aula — Aula 04: Arquitetura de Rede da TechNova

**Aluno:** Matheus Mantovani  
**RA:** 20262  
**Data:** 18/09/2026

---

## Parte 1 — Desenhar a Arquitetura

### Diagrama da rede

```
                          INTERNET
                              │
                              │
                    ┌─────────▼──────────┐
                    │  Internet Gateway   │
                    │   (technova-igw)    │
                    └─────────┬──────────┘
                              │
┌─────────────────────────────▼────────────────────────────────────────┐
│  VPC: 10.0.0.0/16  (technova-vpc)                                    │
│  DNS Support: enabled  |  DNS Hostnames: enabled                     │
│                                                                      │
│  ┌──────────────────────────────┐  ┌──────────────────────────────┐  │
│  │  Subnet Pública AZ-A         │  │  Subnet Pública AZ-B         │  │
│  │  CIDR: 10.0.1.0/24          │  │  CIDR: 10.0.3.0/24          │  │
│  │  AZ: us-east-1a             │  │  AZ: us-east-1b             │  │
│  │  map_public_ip: true        │  │  map_public_ip: true        │  │
│  │                             │  │                             │  │
│  │  Recursos:                  │  │  Recursos:                  │  │
│  │  - EC2 (API Node.js)        │  │  - (futuro: EC2 / ALB)      │  │
│  │                             │  │                             │  │
│  │  SG API Inbound:            │  │                             │  │
│  │  Porta 22  (SSH) ← 0.0.0.0 │  │                             │  │
│  │  Porta 3000 (API) ← 0.0.0.0│  │                             │  │
│  └──────────────────────────────┘  └──────────────────────────────┘  │
│                                                                      │
│  ┌──────────────────────────────┐  ┌──────────────────────────────┐  │
│  │  Subnet Privada AZ-A         │  │  Subnet Privada AZ-B         │  │
│  │  CIDR: 10.0.2.0/24          │  │  CIDR: 10.0.4.0/24          │  │
│  │  AZ: us-east-1a             │  │  AZ: us-east-1b             │  │
│  │  map_public_ip: false       │  │  map_public_ip: false       │  │
│  │                             │  │                             │  │
│  │  Recursos:                  │  │  Recursos:                  │  │
│  │  - (futuro: RDS PostgreSQL) │  │  - (futuro: RDS standby)    │  │
│  │                             │  │                             │  │
│  │  SG DB Inbound:             │  │                             │  │
│  │  Porta 5432 ← 10.0.0.0/16  │  │                             │  │
│  └──────────────────────────────┘  └──────────────────────────────┘  │
│                                                                      │
│  Route Table Pública:                                                │
│    10.0.0.0/16 → local                                               │
│    0.0.0.0/0   → igw (technova-igw)   ← torna a subnet "pública"    │
│                                                                      │
│  Route Table Privada (padrão VPC):                                   │
│    10.0.0.0/16 → local  (apenas tráfego interno)                    │
└──────────────────────────────────────────────────────────────────────┘
```

### Respostas às questões-guia

**Bloco CIDR escolhido e justificativa:**  
`10.0.0.0/16` para a VPC — oferece 65.536 endereços IP, espaço suficiente para crescimento. É um bloco privado RFC 1918, não roteável na internet. O /16 é o padrão mais comum para VPCs de projetos médios. As subnets usam /24 (256 IPs cada), suficiente por zona de disponibilidade.

**Por que a API fica na subnet pública:**  
A API Node.js precisa receber requisições HTTP de clientes na internet (porta 3000). Para isso, a instância EC2 precisa de um IP público e de uma rota para o Internet Gateway. Sem isso, clientes externos não conseguiriam alcançar o servidor.

**Por que o banco fica na subnet privada:**  
O banco de dados nunca deve ser exposto diretamente à internet. Qualquer acesso deve vir apenas da própria API (dentro da VPC). Colocar o banco na subnet privada garante que, mesmo que a porta 5432 estivesse aberta no Security Group, ela seria inacessível por não ter rota para o IGW. É defesa em profundidade: isolamento de rede + firewall.

**Como o banco acessa a internet (atualizações):**  
Precisaria de um **NAT Gateway** na subnet pública. A subnet privada teria uma rota `0.0.0.0/0 → nat-gateway-id`. O NAT traduz os IPs privados para o IP público do NAT, permitindo tráfego de saída (yum update, downloads) sem expor o banco para entrada. O NAT custa ~$32/mês, então não usaremos nos labs.

**Porta SSH aberta para 0.0.0.0/0 — adequado ou não:**  
Não é adequado para produção. Abrir SSH para `0.0.0.0/0` expõe a porta 22 para ataques de força bruta do mundo inteiro. O correto seria restringir ao IP do administrador (`203.0.113.50/32`) ou usar um Bastion Host com MFA. Nos labs, usamos `0.0.0.0/0` apenas por conveniência.

**O que acontece sem rota para o IGW:**  
A subnet deixa de ser "pública" na prática. Instâncias nela podem até ter IP público alocado, mas o tráfego de entrada da internet não chega e o tráfego de saída para a internet é descartado. A API simplesmente não responderia a requisições externas — o curl daria timeout.

---

## Parte 2 — Discussão: Público vs Privado

### Questões múltipla escolha do TA

| Questão | Resposta | Justificativa |
|---------|----------|---------------|
| Q1 — Por que não usar VPC padrão? | **c** | A VPC padrão não oferece isolamento adequado — todos os recursos ficam na mesma rede sem segmentação entre público e privado |
| Q2 — Diferença subnet pública vs privada? | **c** | A subnet pública tem uma rota para o Internet Gateway na sua Route Table, permitindo comunicação com a internet |
| Q3 — O que significa Security Group "stateful"? | **b** | Se uma regra permite tráfego de entrada em uma porta, a resposta de saída é automaticamente permitida sem necessidade de regra explícita |
| Q4 — Função do User Data no EC2? | **c** | Executa um script automaticamente no primeiro boot da instância, permitindo instalar software e configurar a aplicação sem intervenção manual |

### Classificação dos componentes

| Componente | Público ou Privado | Justificativa |
|---|---|---|
| API (Node.js) | **Público** | Precisa receber requisições HTTP da internet na porta 3000. Requer IP público e rota para o IGW. |
| Banco (PostgreSQL) | **Privado** | Apenas a API deve acessá-lo. Expor o banco à internet seria uma vulnerabilidade crítica. |
| Cache (Redis) | **Privado** | Dados sensíveis de sessão/cache. Acesso exclusivamente interno pela API. Sem necessidade de IP público. |
| Load Balancer | **Público** | É o ponto de entrada do tráfego externo. Precisa de IP público para receber requisições dos clientes. |
| Worker (background jobs) | **Privado** | Consome filas internas, não recebe tráfego da internet. Princípio do menor privilégio — sem exposição desnecessária. |
| Bastion Host | **Público** | É o "jump server" para acessar recursos na subnet privada via SSH. Precisa ser acessível da internet, mas com porta 22 restrita ao IP do administrador. |

### Respostas às perguntas provocativas

**"Se tudo ficar na subnet pública, funciona?"**  
Tecnicamente sim, mas viola o princípio do menor privilégio em rede. Um banco de dados na subnet pública poderia ter seu IP exposto e ser atacado diretamente. A separação em subnets públicas/privadas é uma camada adicional de segurança: mesmo que o Security Group esteja mal configurado, o banco sem rota para o IGW já tem proteção de rede.

**"E se o banco precisar baixar patches de segurança?"**  
Precisaria de um NAT Gateway na subnet pública. A subnet privada teria a rota `0.0.0.0/0 → nat-gw`. O NAT permite saída (download de patches) mas bloqueia entrada (ninguém de fora inicia conexão). Custo: ~$32/mês.

**"Quantas subnets públicas/privadas um sistema de produção deveria ter?"**  
Pelo menos 2 de cada, distribuídas em AZs diferentes. Se uma AZ ficar indisponível (falha física, manutenção), os recursos na outra AZ continuam operando. É a base de alta disponibilidade na AWS. O nosso TF já implementa isso: 2 públicas (us-east-1a, us-east-1b) + 2 privadas (us-east-1a, us-east-1b).
