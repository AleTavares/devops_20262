# Trabalho em Aula — Aula 04: Arquitetura de Rede da TechNova

**Aluno:** [FERNANDA TAVARES]  
**RA:** 4025109  
**Data:** 08/09/2026

## Parte 1 — Desenhar a Arquitetura

### Diagrama da rede

```text
VPC: 10.0.0.0/16
|
|-- Subnet pública A: 10.0.1.0/24 (AZ-a)
|   |-- API Node.js / Load Balancer público
|   |-- Bastion Host para acesso administrativo
|   |-- SG: porta 3000 da internet; SSH/22 somente da rede administrativa
|
|-- Subnet pública B: 10.0.2.0/24 (AZ-b)
|   |-- Load Balancer público para alta disponibilidade
|   |-- NAT Gateway para saída das subnets privadas
|
|-- Subnet privada A: 10.0.11.0/24 (AZ-a)
|   |-- PostgreSQL / Redis / workers
|   |-- SG: PostgreSQL/5432 somente do SG da API
|   |-- SG: Redis/6379 somente dos serviços autorizados
|
|-- Subnet privada B: 10.0.12.0/24 (AZ-b)
|   |-- Réplicas futuras do banco, workers e cache
|   |-- SG: sem acesso direto da internet
|
|-- Internet Gateway conectado à VPC
|-- Route Table pública: 10.0.0.0/16 -> local; 0.0.0.0/0 -> Internet Gateway
|-- Route Table privada: 10.0.0.0/16 -> local; 0.0.0.0/0 -> NAT Gateway
```

A arquitetura usa duas subnets públicas e duas privadas em zonas de disponibilidade diferentes. A API pode receber tráfego externo pela porta 3000, mas os componentes internos não possuem rota de entrada direta pela internet.

### Respostas às questões-guia

- **Bloco CIDR escolhido e justificativa:** Foi escolhido `10.0.0.0/16`, que fornece uma faixa privada ampla para a VPC. Ela permite criar várias subnets `/24` em diferentes zonas de disponibilidade e ainda deixa espaço para crescimento futuro.
- **Por que a API fica na subnet pública:** A API Node.js precisa receber requisições da internet na porta 3000. Em produção, o ideal é que o tráfego entre primeiro por um Load Balancer público, que encaminha as requisições para a aplicação.
- **Por que o banco fica na subnet privada:** O PostgreSQL contém dados sensíveis e deve aceitar conexões somente da API, por meio de uma regra de Security Group que use o SG da aplicação como origem. Assim, ele não fica exposto diretamente à internet.
- **Como o banco acessa a internet para atualizações:** A subnet privada pode usar uma rota `0.0.0.0/0` para um NAT Gateway localizado em uma subnet pública. O NAT permite tráfego de saída para baixar atualizações, mas impede conexões iniciadas diretamente da internet.
- **Porta SSH aberta para `0.0.0.0/0` — adequado ou não:** Não é adequado, pois expõe o servidor a tentativas de acesso de qualquer origem. A porta 22 deve aceitar somente o bloco IP da rede administrativa ou ser acessada por um Bastion Host, VPN ou AWS Systems Manager Session Manager.
- **O que acontece sem rota para o IGW:** A subnet pública não terá conectividade com a internet. A API não receberá requisições externas e o acesso administrativo pela internet também falhará, mesmo que o recurso tenha um IP público.

### Security Groups

| Security Group | Regras de entrada | Regras de saída |
|---|---|---|
| `sg-api` | TCP 3000 de `0.0.0.0/0`; SSH/22 somente do SG administrativo ou CIDR autorizado | HTTPS/443 e demais saídas necessárias |
| `sg-banco` | TCP 5432 somente de `sg-api` | Saída para atualizações via NAT Gateway |
| `sg-cache` | TCP 6379 somente de `sg-api` e workers autorizados | Saídas necessárias |
| `sg-bastion` | TCP 22 somente do IP ou CIDR da equipe administrativa | SSH para os recursos privados |

As regras são stateful e seguem o princípio do menor privilégio: cada porta é liberada apenas para a origem que realmente precisa utilizá-la.

## Parte 2 — Discussão: Público vs Privado

### Classificação dos componentes

| Componente | Público ou Privado | Justificativa |
|---|---|---|
| API (Node.js) | Público | Precisa receber requisições externas na porta 3000. Em uma arquitetura mais segura, o acesso público ocorre pelo Load Balancer. |
| Banco (PostgreSQL) | Privado | Deve ser acessado somente pela API e não deve aceitar conexões diretas da internet. |
| Cache (Redis) | Privado | Armazena dados temporários e deve aceitar conexões apenas dos serviços internos autorizados. |
| Load Balancer | Público | É o ponto de entrada do tráfego externo e distribui as requisições para a aplicação. |
| Worker (background jobs) | Privado | Executa tarefas internas e não precisa receber tráfego iniciado pela internet. |
| Bastion Host | Público | Funciona como ponto controlado de entrada administrativa, com SSH restrito aos IPs autorizados. |

### Conclusões da discussão

Manter todos os componentes em subnets públicas poderia fazer o sistema funcionar, mas aumentaria desnecessariamente a superfície de ataque e violaria o princípio do menor privilégio. O banco, o cache e os workers devem permanecer privados.

Para um ambiente de produção, o uso de pelo menos duas subnets públicas e duas privadas, distribuídas em zonas de disponibilidade diferentes, melhora a disponibilidade. O NAT Gateway permite que recursos privados baixem patches sem ficarem publicamente acessíveis.

> A arquitetura proposta separa o tráfego público dos dados e serviços internos, permitindo crescimento futuro e uma implementação mais segura com Terraform.
