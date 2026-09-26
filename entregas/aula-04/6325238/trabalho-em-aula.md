# Trabalho em Aula — Aula 04: Arquitetura de Rede da TechNova

**Aluno:** Yuri Batista Sanches
**RA:** 6325238
**Data:** 24/09/2026

## Parte 1 — Desenhar a Arquitetura

### Diagrama da rede

A arquitetura foi organizada utilizando uma VPC com duas Availability Zones (`us-east-1a` e `us-east-1b`), permitindo separação entre recursos públicos e privados e possibilitando crescimento futuro.

```text
┌─────────────────────────────────────────────────────────────────────┐
│ VPC: 10.0.0.0/16                                                   │
│                                                                     │
│  Availability Zone: us-east-1a       Availability Zone: us-east-1b│
│                                                                     │
│ ┌─────────────────────────┐          ┌─────────────────────────┐   │
│ │ SUBNET PÚBLICA          │          │ SUBNET PÚBLICA          │   │
│ │ 10.0.1.0/24             │          │ 10.0.3.0/24             │   │
│ │                         │          │                         │   │
│ │ EC2 / API Node.js       │          │ EC2 / futuros recursos  │   │
│ │                         │          │ públicos                 │   │
│ └────────────┬────────────┘          └────────────┬────────────┘   │
│              │                                    │                │
│              └──────────────┬─────────────────────┘                │
│                             │                                      │
│                    Internet Gateway                                │
│                             │                                      │
│                          INTERNET                                  │
│                                                                     │
│ ┌─────────────────────────┐          ┌─────────────────────────┐   │
│ │ SUBNET PRIVADA          │          │ SUBNET PRIVADA          │   │
│ │ 10.0.2.0/24             │          │ 10.0.4.0/24             │   │
│ │                         │          │                         │   │
│ │ PostgreSQL / Banco      │          │ Futuros recursos        │   │
│ │ Redis / Workers         │          │ privados                 │   │
│ └─────────────────────────┘          └─────────────────────────┘   │
│                                                                     │
│ Route Table Pública: 0.0.0.0/0 → Internet Gateway                  │
│ Route Table Privada: somente rota local                            │
└─────────────────────────────────────────────────────────────────────┘
```

### Respostas às questões-guia

#### 1. Qual bloco CIDR usar na VPC? Por quê?

Foi escolhido o bloco **10.0.0.0/16** para a VPC. Ele fornece uma quantidade grande de endereços IP privados e permite dividir a rede em várias subnets, facilitando o crescimento futuro da infraestrutura.

As subnets utilizadas foram:

* Pública 1: `10.0.1.0/24`
* Privada 1: `10.0.2.0/24`
* Pública 2: `10.0.3.0/24`
* Privada 2: `10.0.4.0/24`

#### 2. Por que a API fica na subnet pública?

A API Node.js fica na subnet pública porque precisa receber requisições vindas da internet. A subnet pública possui uma rota `0.0.0.0/0` direcionada para o Internet Gateway, permitindo comunicação com a internet.

No laboratório, a API utiliza a porta **3000**.

#### 3. Por que o banco fica na subnet privada?

O banco PostgreSQL deve ficar na subnet privada porque não precisa receber conexões diretamente da internet. Dessa forma, somente os componentes autorizados da infraestrutura podem acessar o banco.

Isso reduz a superfície de exposição e melhora a segurança da arquitetura.

#### 4. Se o banco precisa de atualizações, como acessaria a internet?

Uma alternativa seria utilizar um **NAT Gateway** na subnet pública. A subnet privada poderia utilizar uma rota para o NAT Gateway para acessar a internet de forma que os recursos privados não ficassem diretamente acessíveis pela internet.

Assim, o banco poderia baixar atualizações sem possuir um endereço público ou uma rota direta para o Internet Gateway.

#### 5. A porta SSH (22) deveria estar aberta para `0.0.0.0/0`?

Não é recomendado deixar a porta SSH aberta para `0.0.0.0/0`, pois isso permite tentativas de conexão vindas de qualquer endereço da internet.

O ideal é permitir SSH somente a partir de endereços IP confiáveis, como o IP do administrador ou de uma rede administrativa. Outra alternativa é utilizar um Bastion Host ou outros mecanismos de acesso administrativo controlado.

No laboratório, a porta 22 foi utilizada para permitir o acesso administrativo à instância EC2.

#### 6. O que acontece se esquecermos de criar a rota para o IGW na subnet pública?

A subnet deixaria de ter conectividade adequada com a internet. Mesmo que a instância possua um endereço IP público, sem uma rota `0.0.0.0/0` apontando para o Internet Gateway, o tráfego externo não conseguiria chegar corretamente ao recurso.

Consequentemente, a API Node.js não poderia ser acessada normalmente pela internet.

---

## Parte 2 — Discussão: Público vs Privado

| Componente               | Público ou Privado | Justificativa                                                                                                 |
| ------------------------ | ------------------ | ------------------------------------------------------------------------------------------------------------- |
| API (Node.js)            | Público            | Precisa receber requisições da internet, utilizando a porta 3000.                                             |
| Banco (PostgreSQL)       | Privado            | Não deve ser acessível diretamente pela internet; somente componentes autorizados devem acessá-lo.            |
| Cache (Redis)            | Privado            | Deve ser utilizado internamente pela aplicação e não precisa receber conexões externas.                       |
| Load Balancer            | Público            | Pode ser utilizado como ponto de entrada para requisições externas e encaminhar o tráfego para as aplicações. |
| Worker (background jobs) | Privado            | Executa tarefas internas e não precisa receber requisições diretamente da internet.                           |
| Bastion Host             | Público            | Pode funcionar como ponto controlado de entrada administrativa para acessar recursos privados.                |

## Conclusão

A arquitetura proposta separa os recursos públicos dos recursos privados, permitindo que somente os componentes que precisam receber tráfego externo sejam expostos.

A utilização de duas Availability Zones também permite distribuir os recursos entre diferentes zonas e deixa espaço para expansão futura da infraestrutura.

A estrutura principal utilizada foi:

* VPC: `10.0.0.0/16`
* 2 subnets públicas
* 2 subnets privadas
* Internet Gateway
* Route Table pública
* Route Table privada
* Security Groups
* EC2 para a API Node.js
* PostgreSQL planejado para a camada privada

Essa separação contribui para uma arquitetura mais organizada e reduz a exposição desnecessária dos componentes internos.
