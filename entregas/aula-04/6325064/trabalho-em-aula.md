Trabalho em Aula — Aula 04: Arquitetura de Rede da TechNova

Aluno: Henri da Silva Despezzi
RA: 6325064
Data: 09/09/2026

Parte 1 — Desenhar a Arquitetura
Diagrama da rede
┌─────────────────────────────────────────────────────────────────────┐
│                         VPC: 10.0.0.0/16                            │
│                                                                     │
│  ┌─────────────────────────────┐  ┌─────────────────────────────┐   │
│  │ AZ 1                        │  │ AZ 2                        │   │
│  │                             │  │                             │   │
│  │ ┌─────────────────────────┐ │  │ ┌─────────────────────────┐ │   │
│  │ │ SUBNET PÚBLICA          │ │  │ │ SUBNET PÚBLICA          │ │   │
│  │ │ 10.0.1.0/24             │ │  │ │ 10.0.3.0/24             │ │   │
│  │ │                         │ │  │ │                         │ │   │
│  │ │ EC2 / API Node.js       │ │  │ │ Futura API / LB         │ │   │
│  │ │ IP público              │ │  │ │                         │ │   │
│  │ │                         │ │  │ │                         │ │   │
│  │ │ SG API:                 │ │  │ │ SG API:                 │ │   │
│  │ │ 22  → administração     │ │  │ │ 22  → administração     │ │   │
│  │ │ 3000 → Internet         │ │  │ │ 3000 → Internet         │ │   │
│  │ └─────────────────────────┘ │  │ └─────────────────────────┘ │   │
│  │                             │  │                             │   │
│  │ ┌─────────────────────────┐ │  │ ┌─────────────────────────┐ │   │
│  │ │ SUBNET PRIVADA          │ │  │ │ SUBNET PRIVADA          │ │   │
│  │ │ 10.0.2.0/24             │ │  │ │ 10.0.4.0/24             │ │   │
│  │ │                         │ │  │ │                         │ │   │
│  │ │ PostgreSQL              │ │  │ │ PostgreSQL / Redis      │ │   │
│  │ │ Worker                  │ │  │ │ Worker                  │ │   │
│  │ │                         │ │  │ │                         │ │   │
│  │ │ SG DB:                  │ │  │ │ SG DB:                  │ │   │
│  │ │ 5432 ← VPC             │ │  │ │ 5432 ← VPC             │ │   │
│  │ └─────────────────────────┘ │  │ └─────────────────────────┘ │   │
│  └─────────────────────────────┘  └─────────────────────────────┘   │
│                                                                     │
│                    ┌─────────────────────┐                          │
│                    │ Internet Gateway    │                          │
│                    │        IGW          │                          │
│                    └──────────┬──────────┘                          │
│                               │                                     │
│                    Internet / 0.0.0.0/0                             │
│                                                                     │
│  Route Table Pública:                                               │
│    0.0.0.0/0 → Internet Gateway                                    │
│                                                                     │
│  Route Table Privada:                                               │
│    apenas rota local da VPC                                         │
│    (NAT Gateway seria utilizado futuramente para saída à Internet)  │
└─────────────────────────────────────────────────────────────────────┘


A VPC utiliza o bloco 10.0.0.0/16, permitindo até 65.536 endereços IP no bloco geral e oferecendo espaço suficiente para crescimento futuro. As subnets /24 dividem a rede em segmentos menores e organizados.

A arquitetura foi distribuída em duas Availability Zones para aumentar a disponibilidade e reduzir o impacto de uma eventual falha em uma única zona.

Respostas às questões-guia

Bloco CIDR escolhido e justificativa: Foi escolhido 10.0.0.0/16 por ser um bloco privado amplo, permitindo criar diversas subnets e manter espaço para crescimento futuro da infraestrutura.

Por que a API fica na subnet pública: A API Node.js precisa receber requisições externas pela Internet na porta 3000. Por isso, ela pode ficar em uma subnet pública, com rota para o Internet Gateway.

Por que o banco fica na subnet privada: O PostgreSQL não precisa ser acessível diretamente pela Internet. Mantê-lo em uma subnet privada reduz a superfície de ataque e permite que somente componentes autorizados da VPC tenham acesso ao banco.

Como o banco acessa a Internet para atualizações: Em uma arquitetura de produção, a subnet privada poderia utilizar um NAT Gateway localizado em uma subnet pública. Assim, o banco ou outros recursos privados poderiam iniciar conexões para a Internet para baixar atualizações, sem receber conexões iniciadas diretamente da Internet.

Porta SSH aberta para 0.0.0.0/0 — adequado ou não: Não é o ideal. O acesso SSH deveria ser limitado ao IP ou faixa de IP dos administradores, reduzindo a superfície de ataque. Para uma atividade didática, a abertura para 0.0.0.0/0 pode ser utilizada conforme o requisito, mas em produção deve ser restringida.

O que acontece sem rota para o IGW: Mesmo que a subnet seja chamada de pública, sem uma rota 0.0.0.0/0 apontando para o Internet Gateway os recursos não terão conectividade de saída para a Internet por meio do IGW. A subnet não funcionará efetivamente como uma subnet pública.

Parte 2 — Discussão: Público vs Privado
Classificação dos componentes
Componente	Público ou Privado	Justificativa
API (Node.js)	Público	Precisa receber requisições da Internet na porta 3000.
Banco (PostgreSQL)	Privado	Não deve ser acessível diretamente pela Internet; deve receber conexões somente de componentes autorizados.
Cache (Redis)	Privado	Deve ser acessado internamente pela aplicação e não precisa receber tráfego externo.
Load Balancer	Público	É o ponto de entrada das requisições externas e distribui o tráfego para as aplicações.
Worker (background jobs)	Privado	Não precisa receber requisições diretamente da Internet e deve permanecer isolado.
Bastion Host	Público	Pode servir como ponto controlado de entrada administrativa para acessar recursos privados, embora alternativas como AWS Systems Manager sejam preferíveis em ambientes modernos.
Conclusão

A separação entre subnets públicas e privadas permite aplicar o princípio do menor privilégio na arquitetura de rede.

Os componentes que precisam receber tráfego externo, como um Load Balancer ou a API exposta diretamente nesta atividade, ficam em subnets públicas. Componentes sensíveis, como banco de dados, cache e workers, permanecem em subnets privadas.

A utilização de duas Availability Zones também permite que a arquitetura seja expandida para maior disponibilidade e tolerância a falhas.