# Trabalho em Aula - Aula 04: Arquitetura de Rede da TechNova

**Aluno:** Nicolas Jesus e Silva  
**RA:** 6325171  
**Data:** 10/09/2026

## Parte 1 - Arquitetura

```text
Internet
   |
   v
Internet Gateway
   |
VPC 10.0.0.0/16
   |
   +-- AZ us-east-1a
   |   +-- Publica 10.0.1.0/24 -> Route Table publica -> EC2/API
   |   +-- Privada 10.0.2.0/24 -> rota local -> banco/cache futuro
   |
   +-- AZ us-east-1b
       +-- Publica 10.0.3.0/24 -> Route Table publica
       +-- Privada 10.0.4.0/24 -> rota local -> banco/cache futuro
```

O CIDR `10.0.0.0/16` oferece espaco para crescimento. As subnets `/24` separam os recursos e ficam em duas Availability Zones para melhorar a disponibilidade.

### Respostas as questoes-guia

- **Por que a API fica na subnet publica?** Precisa receber requisicoes externas na porta 3000 e usa rota para o Internet Gateway.
- **Por que o banco fica na subnet privada?** Deve aceitar conexoes somente da aplicacao, nao da internet.
- **Como o banco acessaria a internet para atualizacoes?** Em producao, por NAT Gateway na subnet publica. Ele nao foi criado no laboratorio por ter custo.
- **SSH aberto para `0.0.0.0/0` e adequado?** Nao. O ideal e restringir `ssh_ingress_cidr` ao IP publico do administrador.
- **O que ocorre sem rota para o IGW?** A subnet nao tera caminho para receber ou iniciar trafego externo por essa rota.

## Parte 2 - Publico versus privado

| Componente | Classificacao | Justificativa |
|---|---|---|
| API Node.js | Publico | Recebe requisicoes externas. |
| Banco PostgreSQL | Privado | Deve aceitar trafego somente da aplicacao. |
| Cache Redis | Privado | E acessado internamente e nao deve ser exposto. |
| Load Balancer | Publico | E o ponto de entrada do trafego externo. |
| Worker de background | Privado | Executa tarefas sem entrada publica. |
| Bastion Host | Publico controlado | Ponto de entrada SSH restrito por IP para recursos privados. |
