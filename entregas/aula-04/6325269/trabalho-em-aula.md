# Trabalho em Aula — Aula 04: Arquitetura de Rede da TechNova

**Aluno:** Sirlande Martins
**RA:** 6325269
**Data:** 09/09/2026

## Parte 1 — Desenhar a Arquitetura

### Diagrama da rede

```
                              Internet
                                 │
                          [Internet Gateway]
                                 │
                    Route Table pública (0.0.0.0/0 → IGW)
                          │              │
        ┌─────────────────┘              └─────────────────┐
        │                                                   │
  AZ us-east-1a                                       AZ us-east-1b
┌─────────────────────────┐                     ┌─────────────────────────┐
│ Subnet pública           │                     │ Subnet pública           │
│ 10.0.1.0/24              │                     │ 10.0.3.0/24              │
│                          │                     │                          │
│  EC2 (API Node.js)       │                     │  (reservada para 2ª      │
│  SG: 22 (SSH), 3000 (API)│                     │   instância / futuro LB) │
└─────────────────────────┘                     └─────────────────────────┘

┌─────────────────────────┐                     ┌─────────────────────────┐
│ Subnet privada            │                     │ Subnet privada           │
│ 10.0.2.0/24              │                     │ 10.0.4.0/24              │
│ (Postgres / Redis futuros)│                    │ (Postgres / Redis futuros)│
│ SG: 5432 apenas da VPC    │                     │ SG: 5432 apenas da VPC   │
│ (sem rota para o IGW)     │                     │ (sem rota para o IGW)    │
└─────────────────────────┘                     └─────────────────────────┘

VPC: 10.0.0.0/16
Route Table privada: apenas rota local (sem 0.0.0.0/0)
```

### Respostas às questões-guia

- **Bloco CIDR escolhido e justificativa:** `10.0.0.0/16` para a VPC — é um dos blocos reservados
  para uso privado (RFC 1918), não conflita com redes públicas, e `/16` dá 65.536 IPs, espaço mais
  do que suficiente para crescer em subnets sem precisar redesenhar a rede depois. As subnets usam
  `/24` (256 IPs cada) dentro desse bloco: `10.0.1.0/24` e `10.0.3.0/24` públicas, `10.0.2.0/24` e
  `10.0.4.0/24` privadas — uma de cada tipo por AZ (`us-east-1a` e `us-east-1b`).
- **Por que a API fica na subnet pública:** ela precisa receber requisições HTTP diretamente da
  internet (porta 3000). Sem uma rota para o Internet Gateway e um IP público, nenhum cliente
  externo conseguiria alcançá-la.
- **Por que o banco fica na subnet privada:** o PostgreSQL não deveria estar acessível a partir da
  internet — só a API precisa consultá-lo. Deixá-lo em uma subnet sem rota para o IGW elimina uma
  superfície de ataque inteira (não existe endereço público pra atacar, mesmo que o Security Group
  falhe).
- **Como o banco acessa a internet (atualizações):** subnet privada sozinha não tem saída para a
  internet. Para baixar patches de segurança, precisaria de um **NAT Gateway** em uma subnet
  pública, com uma rota `0.0.0.0/0 → NAT Gateway` na route table da subnet privada — assim o
  tráfego sai, mas nada de fora consegue iniciar conexão de volta.
- **Porta SSH aberta para `0.0.0.0/0` — adequado ou não:** não é adequado para produção. Facilita o
  laboratório, mas expõe a porta 22 a qualquer IP da internet, sujeito a tentativas de força bruta.
  O correto seria restringir `cidr_blocks` ao IP do administrador (`/32`) ou exigir acesso via um
  Bastion Host / VPN.
- **O que acontece sem rota para o IGW:** a subnet continua "pública" apenas em nome — mesmo com
  `map_public_ip_on_launch = true` e um IP público atribuído, sem a rota `0.0.0.0/0 → IGW` na route
  table associada, não existe caminho de ida/volta para a internet. A instância fica isolada, como
  se estivesse em uma subnet privada.

## Parte 2 — Discussão: Público vs Privado

### Classificação dos componentes

| Componente | Público ou Privado | Justificativa |
|---|---|---|
| API (Node.js) | Público | Precisa receber requisições HTTP diretamente da internet |
| Banco (PostgreSQL) | Privado | Só a API deve acessá-lo; não deve ter endereço alcançável de fora |
| Cache (Redis) | Privado | Uso interno entre serviços, dado sensível/de sessão, nenhum motivo para exposição externa |
| Load Balancer | Público | É o ponto de entrada do tráfego externo antes de distribuir para as instâncias |
| Worker (background jobs) | Privado | Consome filas/eventos internos, não recebe requisições HTTP externas |
| Bastion Host | Público | Única porta de entrada SSH controlada para acessar recursos privados, evitando abrir SSH direto neles |
