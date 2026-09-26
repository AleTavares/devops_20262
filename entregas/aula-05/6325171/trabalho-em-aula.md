# Trabalho em Aula - Aula 05: RDS e Remote State

**Aluno:** Nicolas Jesus e Silva  
**RA:** 6325171  
**Data:** 17/09/2026

## Parte 1 - Analise dos Incidentes

### Cenario A: Perda de Dados

1. **Por que os dados foram perdidos:** os pedidos estavam armazenados na memoria RAM ou no armazenamento efemero do EC2, e nao em um banco persistente. Quando a instancia reiniciou, o processo da aplicacao perdeu seu estado.
2. **Outros cenarios de perda:** terminacao ou substituicao da instancia por Auto Scaling; falha de hardware; novo deploy que recria o EC2; erro operacional que apaga o volume ou o container; e falha da aplicacao antes de persistir os dados.
3. **Por que nao reiniciar nao resolve:** evitar reinicios apenas adia o problema. Instancias podem falhar, receber manutencao ou precisar ser substituidas. Uma arquitetura confiavel deve manter os dados fora do ciclo de vida do servidor.
4. **Memoria versus persistencia:** dados em memoria existem somente enquanto o processo e a instancia estao ativos. Dados persistentes ficam gravados em um servico ou armazenamento duravel, como o RDS, e continuam disponiveis depois de reinicios ou substituicoes do EC2.

### Cenario B: Perda do State

1. **`terraform plan` sem state:** o Terraform perde o mapa entre os recursos declarados e os recursos reais. Ele pode interpretar a infraestrutura como inexistente e propor a criacao de recursos duplicados ou apresentar um plano incorreto.
2. **Risco do `terraform apply`:** aplicar esse plano pode duplicar recursos, causar conflitos de nomes, alterar ou destruir componentes inesperadamente e deixar recursos reais sem gerenciamento confiavel.
3. **`terraform import`:** e uma forma de emergencia para registrar recursos existentes em um novo state. Porem, o import nao cria automaticamente toda a configuracao HCL correta; e necessario escrever ou ajustar o codigo e revisar o plano.
4. **Como prevenir:** usar backend remoto S3 com versionamento e encriptacao, DynamoDB para locking, controle de acesso IAM, backup/versionamento do bucket e revisao das mudancas por Pull Request.

## Parte 2 - Design da Arquitetura

```text
Internet
   |
   v
Internet Gateway
   |
VPC 10.0.0.0/16
   |
   +-- us-east-1a
   |   +-- Subnet publica 10.0.1.0/24 -> Route Table publica -> EC2/API
   |   +-- Subnet privada 10.0.2.0/24 ------------------------+
   |                                                          |
   +-- us-east-1b                                             v
       +-- Subnet privada 10.0.4.0/24 -> DB Subnet Group -> RDS PostgreSQL

EC2 Security Group -- permite saida/conexao --> RDS Security Group:5432

S3 (bucket remoto: terraform.tfstate) <--> Terraform
DynamoDB (LockID) -----------------------> locking do state
```

- **Componentes acessiveis da internet:** o Internet Gateway e o EC2 na subnet publica, com as portas estritamente necessarias. A porta SSH deve ser restringida ao IP do administrador sempre que possivel.
- **Componentes isolados:** as duas subnets privadas, o RDS e o state remoto nao devem ficar publicos. O RDS deve ter `publicly_accessible = false` e aceitar a porta 5432 somente do Security Group do EC2 ou, no minimo, do CIDR da VPC.
- **Por que o RDS precisa de 2 AZs:** o DB Subnet Group exige subnets em Availability Zones diferentes. Isso permite failover ou movimentacao futura entre AZs, mesmo quando `multi_az = false` no laboratorio.

## Parte 3 - Discussao: Conflito Simultaneo

- **Cenarios reais:** um deploy de CI/CD executando `apply` enquanto um desenvolvedor aplica uma alteracao manual; dois Pull Requests aprovados ao mesmo tempo; rotinas de emergencia alterando Security Groups; ou duas equipes usando o mesmo ambiente.
- **Impacto de state corrompido:** o Terraform pode perder o vinculo com recursos reais, propor destruicoes ou criacoes incorretas e impedir novas alteracoes ate que o state seja recuperado de uma versao valida.
- **Como o locking resolve:** o DynamoDB registra um lock exclusivo para o state. O primeiro processo adquire o lock, aplica a mudanca e o libera ao terminar. O segundo processo aguarda ou falha informando o lock, evitando que dois processos escrevam sobre o mesmo state simultaneamente.