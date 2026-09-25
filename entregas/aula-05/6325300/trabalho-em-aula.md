# Trabalho em Aula - Aula 05: RDS e Remote State

**Aluno:** Gabriel Carneiro da Silva  
**RA:** 6325300  
**Data:** 24/09/2026

## Parte 1 - Analise dos Incidentes

### Cenario A: Perda de Dados

1. Os dados foram perdidos porque estavam na memoria da aplicacao rodando na EC2. Memoria RAM nao e persistente: quando o processo ou a instancia reinicia, aquilo que nao foi salvo em banco ou disco persistente desaparece.

2. Outros cenarios que causariam a mesma perda:
   - `terraform destroy` seguido de novo `terraform apply`
   - manutencao da AWS reiniciando ou substituindo a instancia
   - crash da aplicacao
   - deploy que recria o container/processo
   - troca manual da EC2 por outra instancia

3. "Nao reiniciar o EC2" nao e solucao porque reinicios podem acontecer por manutencao, falha, deploy, troca de instancia ou necessidade operacional. Infraestrutura precisa tolerar reinicio; nao pode depender de nunca reiniciar.

4. Dados em memoria existem apenas enquanto o processo esta vivo. Dados persistentes ficam em um armazenamento proprio, como RDS/PostgreSQL, e continuam existindo mesmo quando a aplicacao ou a EC2 reinicia.

### Cenario B: Perda do State

1. Sem o `terraform.tfstate`, o Terraform perde o mapa entre o codigo `.tf` e os recursos reais na AWS. Ao rodar `terraform plan`, ele tende a enxergar tudo como recurso novo a criar, porque nao sabe mais o que ja existe.

2. O risco de rodar `terraform apply` nessa situacao e criar recursos duplicados, bater em conflitos de nomes, deixar recursos antigos sem gerenciamento ou piorar o descontrole da infraestrutura.

3. Existe uma solucao de emergencia: `terraform import`. Com ele, e possivel associar recursos existentes ao state novamente, mas isso exige identificar cada recurso manualmente e importar um por um.

4. A prevencao correta e usar remote state em S3, com versionamento e criptografia, e DynamoDB para locking. Assim o state nao fica preso ao notebook de uma pessoa e a equipe trabalha sobre a mesma fonte de verdade.

## Parte 2 - Design da Arquitetura

Arquitetura proposta:

```text
Internet
   |
Internet Gateway
   |
VPC 10.0.0.0/16
   |
   +-- Subnet publica us-east-1a: EC2 API t2.micro
   |      SG EC2: portas 22 e 3000
   |
   +-- Subnet privada us-east-1a
   |      \
   |       DB Subnet Group -> RDS PostgreSQL db.t3.micro
   |      /
   +-- Subnet privada us-east-1b
          SG RDS: porta 5432 apenas do SG da EC2

Fora da VPC:
   - S3 Bucket para terraform.tfstate
   - DynamoDB Table para state locking
```

- Componentes acessiveis da internet: Internet Gateway, subnet publica e EC2 nas portas liberadas pelo Security Group.
- Componentes isolados: subnets privadas, RDS PostgreSQL, S3 de state e DynamoDB de lock.
- O RDS precisa de subnets em 2 AZs porque o DB Subnet Group exige subnets em zonas diferentes. Isso prepara a arquitetura para resiliencia e para Multi-AZ no futuro, mesmo quando `multi_az = false`.

## Parte 3 - Discussao: Conflito Simultaneo

- Cenarios reais: um desenvolvedor roda `terraform apply` enquanto a pipeline de CI/CD tambem aplica mudancas; dois membros da equipe fazem alteracoes diferentes ao mesmo tempo; alguem altera rede enquanto outra pessoa altera EC2 ou RDS.
- Impacto de state corrompido: Terraform pode esquecer mudancas, tentar recriar recursos, perder capacidade de destruir recursos corretamente e deixar a infraestrutura divergente do codigo.
- Como locking resolve: o DynamoDB cria um lock durante o `apply`. Enquanto um processo esta aplicando, outro precisa esperar. Quando o primeiro termina, o segundo le o state atualizado e aplica com base na realidade mais recente.
