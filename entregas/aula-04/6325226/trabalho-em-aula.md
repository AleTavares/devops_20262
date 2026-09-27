# Trabalho em Aula — Aula 04: Arquitetura de Rede da TechNova

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 2026-08-29

## Parte 1 — Desenhar a Arquitetura

### Diagrama da rede

```
┌──────────────────────────────────────────────────────────────────────┐
│  VPC: 10.0.0.0/16                                                     │
│                                                                        │
│  ┌─── AZ us-east-1a ─────────────┐  ┌─── AZ us-east-1b ─────────────┐ │
│  │                                │  │                                │ │
│  │  Subnet Pública                │  │  Subnet Pública                │ │
│  │  CIDR: 10.0.1.0/24             │  │  CIDR: 10.0.3.0/24             │ │
│  │  Recursos:                     │  │  Recursos:                     │ │
│  │  - EC2 API Node.js (t2.micro)  │  │  - (reservada p/ 2ª instância   │ │
│  │  - futuro: nó do ALB           │  │    ou nó do ALB — Multi-AZ)     │ │
│  │  SG Inbound:                   │  │  SG Inbound:                   │ │
│  │  Porta 22   de 0.0.0.0/0       │  │  Porta 22   de 0.0.0.0/0       │ │
│  │  Porta 3000 de 0.0.0.0/0       │  │  Porta 3000 de 0.0.0.0/0       │ │
│  │                                │  │                                │ │
│  │  Subnet Privada                │  │  Subnet Privada                │ │
│  │  CIDR: 10.0.2.0/24             │  │  CIDR: 10.0.4.0/24             │ │
│  │  Recursos:                     │  │  Recursos:                     │ │
│  │  - futuro: RDS PostgreSQL      │  │  - futuro: RDS PostgreSQL       │ │
│  │    (standby Multi-AZ)          │  │    (réplica/standby)            │ │
│  │  SG Inbound:                   │  │  SG Inbound:                   │ │
│  │  Porta 5432 de 10.0.0.0/16     │  │  Porta 5432 de 10.0.0.0/16     │ │
│  └────────────────────────────────┘  └────────────────────────────────┘ │
│                                                                        │
│  Internet Gateway: [x] conectado à VPC                                │
│                                                                        │
│  Route Table Pública: 0.0.0.0/0 → Internet Gateway                    │
│                        (associada às DUAS subnets públicas)           │
│  Subnets Privadas: usam a Route Table padrão da VPC (só rota local,   │
│                     sem rota para o IGW)                              │
└──────────────────────────────────────────────────────────────────────┘
```

### Respostas às questões-guia

- **Bloco CIDR escolhido e justificativa:** `10.0.0.0/16` para a VPC (65.536 IPs) — é o bloco privado padrão de laboratório, com espaço de sobra para crescer (novas subnets, novas AZs, novos ambientes) sem precisar recriar a VPC. As subnets usam `/24` (256 IPs cada), suficiente para os recursos atuais e futuros (EC2, ALB, RDS) sem desperdiçar todo o espaço da VPC em uma única subnet.
- **Por que a API fica na subnet pública:** ela precisa receber requisições HTTP diretamente da internet na porta 3000; para isso precisa de IP público (`map_public_ip_on_launch = true`) e de uma rota `0.0.0.0/0 → IGW`, que só a subnet pública tem.
- **Por que o banco fica na subnet privada:** o PostgreSQL nunca deveria ser alcançável diretamente da internet — só a API (dentro da própria VPC) precisa falar com ele. Ficando numa subnet sem rota para o IGW, mesmo que o Security Group tivesse uma regra errada, o banco continuaria inacessível externamente.
- **Como o banco acessaria a internet para atualizações:** precisaria de um **NAT Gateway** numa subnet pública, com a Route Table da subnet privada apontando `0.0.0.0/0 → NAT Gateway`. Isso permite tráfego de saída (baixar patches) sem expor o banco a conexões de entrada vindas da internet.
- **Porta SSH aberta para 0.0.0.0/0 — adequado ou não:** não é adequado em produção. Usamos `0.0.0.0/0` neste laboratório só para simplificar o acesso durante o desenvolvimento; o correto seria restringir a porta 22 ao IP (ou faixa de IPs) do administrador, ou substituir o SSH direto por um Bastion Host / AWS Systems Manager Session Manager.
- **O que acontece sem a rota para o IGW:** a subnet continua "pública" apenas no nome — as instâncias recebem IP público, mas nenhum pacote entra ou sai pela internet, porque a Route Table não sabe para onde mandar o tráfego `0.0.0.0/0`. Na prática, a API ficaria inacessível externamente mesmo com Security Group liberado.

## Parte 2 — Discussão: Público vs Privado

### Classificação dos componentes

| Componente | Público ou Privado | Justificativa |
|---|---|---|
| API (Node.js) | Público | Precisa receber requisições HTTP da internet na porta 3000; sem IP público e rota para o IGW, ninguém de fora conseguiria chamar a API. |
| Banco (PostgreSQL) | Privado | Só a API (de dentro da VPC) precisa se conectar nele; expô-lo à internet aumentaria enormemente a superfície de ataque para nenhum benefício funcional. |
| Cache (Redis) | Privado | Acesso é exclusivamente interno (API/workers lendo e escrevendo cache) e os dados costumam ser sensíveis ou de sessão — não há motivo para tráfego externo chegar até ele. |
| Load Balancer | Público | É o ponto de entrada do tráfego externo — precisa estar na subnet pública para receber conexões da internet e distribuí-las para os targets (que podem ficar em subnets privadas). |
| Worker (background jobs) | Privado | Consome filas/eventos internos e não expõe nenhuma porta HTTP para o mundo externo; não precisa e não deveria ser alcançável de fora. |
| Bastion Host | Público | É a única porta de entrada SSH controlada para a rede — fica na subnet pública justamente para que os administradores acessem por ele, e a partir dele saltem para os recursos privados, em vez de abrir SSH direto em cada máquina privada. |

### Perguntas provocativas — respostas

- **"Se tudo ficar na subnet pública, funciona?"** Funciona tecnicamente, mas é inseguro: cada recurso público exposto (banco, cache, workers) é uma porta a mais de ataque direto pela internet, violando o princípio do menor privilégio em rede — a regra deveria ser "só fica público o que precisa receber tráfego externo".
- **"E se o banco precisar baixar patches de segurança?"** Precisa de um NAT Gateway numa subnet pública, com a Route Table privada roteando `0.0.0.0/0` para ele — assim o banco consegue iniciar conexões de saída (para os repositórios de patch) sem nunca aceitar conexões de entrada vindas da internet.
- **"Quantas subnets públicas/privadas um sistema de produção deveria ter?"** Pelo menos 2 de cada, em AZs diferentes, para alta disponibilidade — é exatamente o desenho implementado no TF desta aula (`10.0.1.0/24`/`10.0.3.0/24` públicas e `10.0.2.0/24`/`10.0.4.0/24` privadas, em `us-east-1a` e `us-east-1b`), preparando o terreno para um Load Balancer (que exige subnets em ao menos 2 AZs) e para um RDS Multi-AZ.
