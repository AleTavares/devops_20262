# Trabalho em Aula — Aula 05: RDS e Remote State

**Aluno:** Gabriel Reis Cunha
**RA:** 6325149
**Data:** 03/09/2026

## Parte 1 — Análise dos Incidentes

### Cenário A: Perda de Dados

1. **Por que os dados foram perdidos:** a API não usava nenhum banco de dados
   persistente — os pedidos ficavam guardados só na **memória (RAM)** do processo
   Node.js rodando no EC2 (um array/objeto em memória, sem gravação em disco nem em
   um serviço externo). Ao reiniciar a instância, o processo é finalizado e recriado
   do zero: a memória é limpa e não existe nenhum lugar de onde recuperar os 5
   pedidos. Um simples reboot programado já basta, nem precisa terminar a instância.

2. **Outros cenários que causariam a mesma perda (mín. 3):**
   - Deploy de uma nova versão da aplicação (o processo é reiniciado para carregar
     o novo código).
   - Crash da aplicação por uma exceção não tratada (o processo morre e sobe de
     novo vazio).
   - Auto Scaling substituindo a instância por uma nova (a memória da instância
     antiga simplesmente não existe na nova).
   - Manutenção de host da própria AWS migrando a instância para outro hardware
     físico (o que aconteceu no cenário descrito).
   - Alguém rodando `terraform apply` com uma mudança que força replace do EC2
     (ex.: trocar a AMI ou o `user_data`).

3. **Por que "não reiniciar o EC2" não é solução válida:** reinícios não são uma
   escolha do time — a AWS reinicia hosts por manutenção, hardware falha, deploys
   precisam reiniciar o processo, Auto Scaling substitui instâncias. Tentar evitar
   reinícios ataca o sintoma, não a causa raiz (falta de armazenamento persistente).
   Além disso, é operacionalmente insustentável: qualquer atualização de código ou
   patch de segurança do sistema também exigiria manter o processo no ar para
   sempre, o que é impraticável.

4. **Dados em memória vs. dados persistentes:** dados em memória existem apenas
   enquanto o processo que os criou está rodando — são voláteis, rápidos de acessar,
   mas desaparecem em qualquer reinício, crash ou substituição da instância. Dados
   persistentes são gravados em um armazenamento duradouro (disco, ou melhor ainda,
   um banco de dados gerenciado como o RDS) que sobrevive independentemente do que
   acontece com o servidor de aplicação. É exatamente a separação implementada no
   Lab: o EC2 (camada de processamento, descartável) fica isolado do RDS (camada de
   dados, persistente) — reiniciar, substituir ou até terminar o EC2 não afeta uma
   linha sequer do banco.

### Cenário B: Perda do State

1. **O que acontece com `terraform plan` sem o state, e por quê:** o Terraform
   decide o que fazer comparando três fontes: o código `.tf` (desejado), o state
   (o que ele *acha* que já existe) e a API da AWS. Sem o state, a segunda fonte
   fica vazia — o Terraform não tem nenhuma memória do que já provisionou. Ele
   então trata **cada recurso do código como se não existisse**, e o `plan` mostra
   tudo como "to add" (criar do zero), mesmo que a VPC, o RDS e o EC2 estejam rodando
   normalmente na AWS.

2. **Risco de rodar `terraform apply` nessa situação:** o Terraform tentaria criar
   recursos duplicados. Alguns falhariam por conflito de nome único (ex.: bucket S3),
   mas outros (VPC, subnets, EC2, RDS) seriam criados **de novo, em paralelo** aos
   que já existem — dobrando o custo, criando uma segunda VPC desconectada da
   aplicação real, e deixando a infraestrutura em um estado confuso e caro até
   alguém perceber e limpar manualmente.

3. **`terraform import` como solução de emergência:** sim, existe — permite
   "adotar" um recurso que já existe na AWS de volta para dentro de um state novo
   (`terraform import aws_instance.api i-0123...`), recurso por recurso. É viável,
   mas lento e arriscado: cada import exige saber o ID exato do recurso, e o
   Terraform não preenche sozinho os atributos do `.tf` — se o código não bater
   exatamente com a configuração real, o próximo `plan` mostra mudanças indevidas
   (drift) que podem alterar ou destruir o recurso sem querer.

4. **Como essa situação poderia ter sido prevenida:** exatamente com o que foi
   implementado no Lab Parte 2 — um **backend remoto** (bucket S3 versionado +
   trava no DynamoDB). O state nunca vive só no laptop de uma pessoa; ele fica
   centralizado na nuvem, acessível por toda a equipe, e com versionamento
   habilitado é possível voltar a uma versão anterior se algo corromper. Perder o
   laptop do Rafael deixaria de ser um incidente de infraestrutura.

## Parte 2 — Design da Arquitetura

```
                              Internet
                                 │
                        ┌────────┴────────┐
                        │ Internet Gateway │
                        └────────┬────────┘
      VPC 10.0.0.0/16            │
      ┌───────────────────────────────────────────────────────────┐
      │  Subnet PÚBLICA (us-east-1a)                               │
      │     ┌───────────────┐   SG: entrada 22 (SSH) e 3000 (API)  │
      │     │  EC2 t2.micro  │   de 0.0.0.0/0                      │
      │     │  (API Node.js) │                                     │
      │     └───────┬───────┘                                      │
      │             │ porta 5432, só de dentro da VPC               │
      │  ─ ─ ─ ─ ─ ─┼─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─   │
      │  Subnet PRIVADA (us-east-1a) ┐                              │
      │  Subnet PRIVADA (us-east-1b) ┼─ DB Subnet Group             │
      │     ┌──────────────────────┐ ┘  SG: entrada 5432 só do      │
      │     │  RDS PostgreSQL       │   CIDR da VPC/SG do EC2       │
      │     │  (subnets privadas)   │   sem rota para a internet    │
      │     └──────────────────────┘                                │
      └───────────────────────────────────────────────────────────┘

      Fora da VPC (state do Terraform, não é dado de aplicação):
      ┌───────────────────┐        ┌───────────────────────┐
      │   S3 Bucket        │        │   DynamoDB Table       │
      │  terraform.tfstate │        │  lock (LockID)         │
      │  versionado + SSE  │        │                        │
      └───────────────────┘        └───────────────────────┘
```

- **Componentes acessíveis pela internet:** só o **EC2**, e só nas portas 22 (SSH)
  e 3000 (API) — porque ele está na subnet pública com IP público e o Security
  Group libera essas duas portas de `0.0.0.0/0`.
- **Componentes isolados:** o **RDS** está totalmente isolado da internet — vive
  em subnets privadas (sem rota para o Internet Gateway), tem `publicly_accessible
  = false`, e o Security Group só aceita a porta 5432 vindo de dentro da própria
  VPC. Mesmo que alguém descobrisse o endpoint do banco, não haveria como rotear
  até ele de fora. O **S3** e o **DynamoDB** do state ficam fora da VPC (são
  serviços regionais, não "dentro" de uma rede), mas também não são públicos:
  Block Public Access (4/4) no bucket e permissões IAM controlam quem acessa.
- **Por que o RDS precisa de subnets em 2 AZs mesmo sem Multi-AZ:** é uma exigência
  estrutural do **DB Subnet Group** da AWS — ele só aceita ser criado com subnets
  cobrindo pelo menos duas Availability Zones, mesmo que a instância use só uma
  delas no dia a dia. Isso deixa a porta aberta para ativar Multi-AZ depois sem
  precisar reconstruir a rede, e a AWS também usa essa segunda AZ durante
  manutenção da instância (pode mover o RDS para lá temporariamente).

## Parte 3 — Discussão: Conflito Simultâneo

- **Cenários reais onde isso ocorreria:** um pipeline de CI/CD rodando
  `terraform apply` automaticamente a cada merge na `main`, enquanto um
  desenvolvedor roda `apply` manualmente do laptop para testar uma mudança local;
  dois integrantes do mesmo squad mexendo na mesma stack ao mesmo tempo sem avisar
  um ao outro (exatamente o cenário do Dev A / Dev B); ou um job agendado de
  correção de drift disparando junto com uma mudança manual de emergência.

- **Impacto de um state corrompido:** o Terraform perde a correspondência
  confiável entre o que ele "acha" que existe e o que de fato está provisionado.
  Os próximos `plan`/`apply` deixam de ser confiáveis — podem tentar recriar
  recursos que já existem (duplicando custo), ou "esquecer" recursos que ficam
  órfãos (não gerenciados, gerando custo invisível), ou na pior hipótese, destruir
  algo em produção por engano ao tentar reconciliar um estado inconsistente.

- **Como o locking resolve:** a tabela DynamoDB funciona como um **mutex
  distribuído**. Antes de ler ou escrever o state, o Terraform tenta gravar um item
  de lock (`LockID`) na tabela; se o item já existir (outra operação está em
  andamento), a segunda tentativa fica bloqueada — espera ou falha com "Error
  acquiring the state lock" — em vez de seguir em frente com um state
  desatualizado. Isso serializa as operações: Dev A aplica, libera o lock, só então
  Dev B consegue aplicar sua mudança em cima do state já atualizado. Nenhuma das
  duas mudanças é perdida.
