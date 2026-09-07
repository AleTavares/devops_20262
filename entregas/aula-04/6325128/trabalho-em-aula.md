# Trabalho em Aula — Aula 04: Arquitetura de Rede da TechNova

**Aluno:** Felipe Damasceno
**RA:** 6325128  
**Data:** 03/09/2026

---

## Parte 1 — Desenhar a Arquitetura

### Diagrama da Rede

```
┌──────────────────────────────────────────────────────────────────┐
│  VPC: 10.0.0.0 / 16                                              │
│                                                                  │
│  ┌─── Subnet Pública ──────────┐  ┌─── Subnet Privada ────────┐  │
│  │  CIDR: 10.0.1.0/24          │  │  CIDR: 10.0.2.0/24        │  │
│  │                             │  │                           │  │
│  │  Recursos:                  │  │  Recursos:                │  │
│  │  - EC2 (API Node.js :3000)  │  │  - RDS PostgreSQL :5432   │  │
│  │  - Bastion Host (SSH :22)   │  │  - ElastiCache Redis      │  │
│  │                             │  │  - Workers (background)   │  │
│  │  SG Inbound:                │  │                           │  │
│  │  Porta 3000 de 0.0.0.0/0    │  │  SG Inbound:              │  │
│  │  Porta 22  de IP admin      │  │  Porta 5432 de SG da API  │  │
│  │  Porta 80  de 0.0.0.0/0     │  │  Porta 6379 de SG da API  │  │
│  │  Porta 443 de 0.0.0.0/0     │  │  Porta 22   de SG Bastion │  │
│  └─────────────────────────────┘  └───────────────────────────┘  │
│                                                                  │
│  Internet Gateway: [IGW] conectado à VPC                         │
│                                                                  │
│  Route Table Pública: 0.0.0.0/0 → Internet Gateway (IGW)        │
│  Route Table Privada: 0.0.0.0/0 → NAT Gateway (para saída)      │
│                       10.0.0.0/16 → local                        │
└──────────────────────────────────────────────────────────────────┘
```

---

### Respostas às Questões-Guia

**1. Qual bloco CIDR usar na VPC? Por quê?**

Escolhemos `10.0.0.0/16`. Esse bloco pertence ao espaço de endereços privados definidos pela RFC 1918 e oferece 65.536 endereços IP, o que é mais do que suficiente para o tamanho atual da TechNova e permite espaço para crescimento futuro — novas subnets em outras Availability Zones, novos ambientes (staging, produção) e novos serviços. O prefixo `/16` é o recomendado pela AWS para VPCs que precisam de escalabilidade, pois as subnets são criadas com prefixos menores (ex.: `/24`) dentro desse espaço.

**2. Por que a API fica na subnet pública e o banco na privada?**

A API Node.js precisa receber requisições originadas da internet, portanto deve estar em uma subnet que possui rota para o Internet Gateway (subnet pública). O banco de dados PostgreSQL, por outro lado, não deve ser acessado diretamente por nenhum cliente externo — apenas pela própria API. Colocá-lo na subnet privada garante que não exista rota de entrada vinda da internet, reduzindo drasticamente a superfície de ataque.

**3. Se o banco precisa de atualizações, como acessaria a internet sem estar público?**

Através de um **NAT Gateway** posicionado na subnet pública. O NAT Gateway permite que recursos da subnet privada iniciem conexões de saída para a internet (para baixar patches, por exemplo), mas bloqueia qualquer conexão de entrada originada externamente. Dessa forma o banco permanece inacessível de fora, mas consegue buscar atualizações quando necessário.

**4. A porta SSH (22) deveria estar aberta para `0.0.0.0/0`? Por quê não?**

Não. Abrir a porta 22 para qualquer endereço IP expõe a instância a varreduras e tentativas de força bruta vindas de qualquer lugar da internet. A prática correta é restringir o acesso SSH a IPs específicos dos administradores (ex.: `203.0.113.50/32`) ou, melhor ainda, utilizar um **Bastion Host**: o SSH externo só é permitido para a instância bastion, e a partir dela os administradores saltam para as instâncias privadas. Isso aplica o princípio do menor privilégio.

**5. O que acontece se esquecermos de criar a rota para o IGW na subnet pública?**

A subnet pública passa a se comportar como privada: as instâncias não conseguem receber tráfego originado da internet nem enviar respostas para clientes externos. A API Node.js ficaria completamente inacessível, pois os pacotes não saberiam por onde sair da VPC rumo à internet.

---

## Parte 2 — Discussão: Público vs Privado

### Classificação dos Componentes

| Componente             | Público ou Privado | Justificativa |
|---|---|---|
| API (Node.js)          | **Público**  | Precisa receber requisições HTTP/HTTPS originadas da internet na porta 3000. Deve ter IP público ou estar atrás de um Load Balancer público. |
| Banco (PostgreSQL)     | **Privado**  | Deve ser acessado exclusivamente pela API. Expô-lo à internet violaria o princípio do menor privilégio e criaria um vetor de ataque direto a dados sensíveis. |
| Cache (Redis)          | **Privado**  | Contém dados em memória potencialmente sensíveis (sessões, tokens). Só a API e os workers precisam acessá-lo; nenhum tráfego externo é necessário. |
| Load Balancer          | **Público**  | É o ponto de entrada de todo o tráfego externo. Fica exposto na internet e distribui as requisições para as instâncias da API nas subnets públicas (ou privadas, dependendo da arquitetura). |
| Worker (background jobs) | **Privado** | Processa tarefas de fila de forma assíncrona sem precisar receber conexões externas. Colocá-lo em subnet privada limita sua exposição e é suficiente para seu funcionamento. |
| Bastion Host           | **Público**  | É a única porta de entrada segura para acesso SSH administrativo. Fica na subnet pública com acesso restrito a IPs de admins, e a partir dele se acessa por SSH os recursos das subnets privadas. |

### Respostas às Perguntas Provocativas

**"Se tudo ficar na subnet pública, funciona?"**

Tecnicamente sim — os serviços se comunicam e a aplicação opera. Porém, isso viola o princípio do menor privilégio em rede: o banco de dados e o cache estariam expostos à internet, aumentando enormemente a superfície de ataque. Um Security Group mal configurado ou uma regra esquecida poderia expor dados críticos diretamente. Em produção, isso é inaceitável.

**"E se o banco precisar baixar patches de segurança?"**

Seria necessário provisionar um **NAT Gateway** na subnet pública e adicionar uma rota `0.0.0.0/0 → NAT Gateway` na Route Table da subnet privada. O NAT Gateway traduz os endereços de saída, permitindo que o banco inicie conexões com a internet para baixar atualizações, sem que a internet consiga iniciar conexões de entrada com ele.

**"Quantas subnets públicas/privadas um sistema de produção deveria ter?"**

Pelo menos **2 subnets públicas e 2 subnets privadas**, cada par em uma Availability Zone (AZ) diferente. Isso garante **alta disponibilidade**: se uma AZ sofrer uma falha, a outra continua servindo o tráfego. Em sistemas críticos, 3 AZs são ainda mais recomendadas. O Load Balancer e o RDS Multi-AZ aproveitam essa distribuição automaticamente.