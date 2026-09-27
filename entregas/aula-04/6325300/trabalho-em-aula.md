# Trabalho em Aula - Aula 04: Arquitetura de Rede da TechNova

**Aluno:** Gabriel Carneiro da Silva  
**RA:** 6325300  
**Data:** 10/09/2026

## Parte 1 - Desenhar a Arquitetura

### Diagrama da rede

```text
Internet
   |
   v
Internet Gateway
   |
   v
VPC TechNova - 10.0.0.0/16
|
|-- Subnet publica A - 10.0.1.0/24
|   |-- API Node.js / EC2
|   |-- Security Group API: 22 e 3000 de 0.0.0.0/0
|
|-- Subnet privada A - 10.0.2.0/24
|   |-- Banco PostgreSQL futuro
|   |-- Security Group DB: 5432 apenas de 10.0.0.0/16
|
|-- Subnet publica B - 10.0.3.0/24
|   |-- Espaco para Load Balancer ou redundancia futura
|
`-- Subnet privada B - 10.0.4.0/24
    `-- Espaco para banco/cache/worker em alta disponibilidade

Route Table publica: 0.0.0.0/0 -> Internet Gateway
Route Table privada: apenas rota local da VPC
```

### Respostas as questoes-guia

- Bloco CIDR escolhido e justificativa: `10.0.0.0/16`, porque oferece muitos enderecos e permite dividir a rede em varias subnets `/24` sem conflito.
- Por que a API fica na subnet publica: porque precisa receber requisicoes externas na porta 3000.
- Por que o banco fica na subnet privada: porque o banco nao deve ser acessado diretamente pela internet; apenas a API ou servicos internos devem falar com ele.
- Como o banco acessa a internet para atualizacoes: em producao, por meio de um NAT Gateway em subnet publica. No laboratorio, evitamos NAT para nao gerar custo.
- Porta SSH aberta para `0.0.0.0/0` - adequado ou nao: atende ao exercicio, mas nao e adequado para producao; o correto seria restringir ao IP dos administradores, usar bastion host ou AWS Systems Manager.
- O que acontece sem rota para o IGW: a subnet publica deixa de ser publica; recursos nela nao conseguem receber/acessar trafego da internet diretamente.

## Parte 2 - Discussao: Publico vs Privado

### Classificacao dos componentes

| Componente | Publico ou Privado | Justificativa |
|---|---|---|
| API (Node.js) | Publico | Precisa receber requisicoes dos usuarios pela internet |
| Banco (PostgreSQL) | Privado | Deve ser acessado apenas por servicos internos, como a API |
| Cache (Redis) | Privado | Guarda dados internos e nao deve receber trafego externo |
| Load Balancer | Publico | Atua como ponto de entrada para usuarios externos |
| Worker (background jobs) | Privado | Executa tarefas internas e nao precisa de acesso direto da internet |
| Bastion Host | Publico | Serve como ponto controlado de entrada SSH para acessar recursos privados |

## Conclusao

A arquitetura separa o que precisa estar exposto do que deve ficar protegido. A VPC customizada, as subnets publicas/privadas, as Route Tables e os Security Groups reduzem o risco de expor banco/cache diretamente e deixam a TechNova preparada para crescer com mais disponibilidade.
