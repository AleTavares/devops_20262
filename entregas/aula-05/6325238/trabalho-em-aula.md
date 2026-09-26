# Trabalho em Aula — Aula 05: RDS e Remote State

**Aluno:** Yuri Sanches
**RA:** [6325238]
**Data:** 24/09/2026

## Parte 1 — Análise dos Incidentes

### Cenário A: Perda de Dados

**1. Por que os dados foram perdidos? (Onde estavam armazenados?)**

Os dados foram perdidos porque estavam armazenados localmente na instância EC2, provavelmente no armazenamento temporário ou em uma aplicação que mantinha os dados apenas em memória. Quando a instância foi reiniciada, esses dados não estavam em um armazenamento persistente e foram perdidos.

**2. Quais outros cenários causariam a mesma perda?**

Alguns exemplos são:

* Encerramento ou substituição da instância EC2.
* Falha no disco ou no armazenamento local da instância.
* Alteração da infraestrutura que recrie a instância.
* Falha ou reinicialização inesperada do servidor sem armazenamento persistente.

**3. Por que simplesmente "não reiniciar o EC2" não é uma solução válida?**

Porque uma instância EC2 pode ser reiniciada, substituída ou apresentar falhas por diversos motivos. Além disso, depender de uma única máquina não garante a segurança dos dados. A solução correta é armazenar os dados em um serviço persistente, como o Amazon RDS.

**4. Qual a diferença entre "dados em memória" e "dados persistentes"?**

Dados em memória ficam armazenados temporariamente na RAM e podem ser perdidos quando a aplicação ou servidor é reiniciado. Dados persistentes são armazenados em recursos que mantêm as informações mesmo após reinicializações, como bancos de dados, discos persistentes ou serviços de armazenamento.

---

### Cenário B: Perda do State

**1. O que acontece se rodarem `terraform plan` sem o state? Por quê?**

O Terraform perde a referência sobre os recursos que já existem na AWS. Sem o state, ele não consegue comparar corretamente a infraestrutura atual com a configuração `.tf`, podendo interpretar os recursos existentes como novos.

**2. Qual é o risco de rodar `terraform apply` nessa situação?**

Existe o risco de o Terraform tentar criar novamente recursos que já existem ou realizar alterações incorretas na infraestrutura. Isso pode gerar recursos duplicados, conflitos, custos adicionais ou até indisponibilidade.

**3. Existe forma de "importar" recursos existentes? (`terraform import`)**

Sim. O Terraform possui o comando `terraform import`, que permite associar um recurso que já existe na AWS a um recurso definido na configuração Terraform. Dessa forma, é possível reconstruir o state aos poucos.

**4. Como essa situação poderia ter sido prevenida?**

O problema poderia ser prevenido utilizando um **Remote State**, armazenando o `terraform.tfstate` em um bucket S3. Também é importante utilizar um mecanismo de locking, como o DynamoDB, para evitar que várias pessoas alterem o state simultaneamente. Além disso, o state não deve ser versionado diretamente no Git, principalmente porque pode conter informações sensíveis.

---

## Parte 2 — Design da Arquitetura

A arquitetura proposta para a TechNova possui uma VPC dividida em subnets públicas e privadas.

### Componentes da arquitetura

* **VPC:** rede isolada da aplicação, utilizando um CIDR block.
* **2 Availability Zones:** `us-east-1a` e `us-east-1b`.
* **Subnet pública:** utilizada pela instância EC2 que hospeda a API.
* **2 Subnets privadas:** uma em cada Availability Zone, utilizadas pelo RDS.
* **Internet Gateway:** permite que a subnet pública tenha acesso à internet.
* **EC2:** fica na subnet pública e hospeda a API.
* **Security Group da EC2:** permite as portas necessárias, como SSH (22) e aplicação (3000).
* **RDS PostgreSQL:** fica nas subnets privadas.
* **Security Group do RDS:** permite a porta 5432 somente para o Security Group da EC2.
* **S3:** fica fora da VPC e armazena o Terraform State.
* **DynamoDB:** utilizado para controlar o locking do Terraform State.

### Componentes acessíveis da internet

A EC2 está na subnet pública e pode receber acesso da internet através do Internet Gateway, conforme as regras configuradas no Security Group.

O RDS não deve ser acessível diretamente pela internet. A comunicação com ele acontece através da EC2, utilizando a porta 5432 dentro da VPC.

### Componentes isolados

As subnets privadas utilizadas pelo RDS são isoladas do acesso direto da internet. O banco pode receber conexões da EC2 através das regras do Security Group.

O Terraform State armazenado no S3 também não precisa ficar dentro da VPC, pois o acesso ao serviço é feito através da infraestrutura da AWS.

### Por que o RDS precisa de 2 AZs?

O RDS precisa de subnets em pelo menos duas Availability Zones para formar o **DB Subnet Group**. Isso permite que a infraestrutura do banco tenha opções em diferentes zonas de disponibilidade e fornece uma arquitetura preparada para maior disponibilidade.

Mesmo que o RDS não esteja utilizando Multi-AZ, o DB Subnet Group precisa estar associado a subnets de pelo menos duas Availability Zones.

---

## Parte 3 — Discussão: Conflito Simultâneo

### Cenários reais onde isso poderia ocorrer

Esse problema pode acontecer quando duas ou mais pessoas executam `terraform apply` ao mesmo tempo. Também pode ocorrer quando uma pipeline de CI/CD executa alterações enquanto um desenvolvedor realiza uma alteração manualmente.

Por exemplo, um desenvolvedor pode estar alterando uma EC2 enquanto uma pipeline está modificando regras de Security Group.

### Impacto de um state corrompido

Um state corrompido pode fazer com que o Terraform perca a referência correta dos recursos existentes. Isso pode causar alterações incorretas, recursos duplicados, dificuldades para gerenciar a infraestrutura e até indisponibilidade de serviços.

Por isso, o state é uma parte muito importante do gerenciamento da infraestrutura com Terraform.

### Como o locking resolve?

O locking impede que duas operações do Terraform alterem o mesmo state ao mesmo tempo.

Quando o Dev A adquire o lock, o Dev B precisa aguardar. Depois que o Dev A termina e libera o lock, o Dev B pode executar sua alteração utilizando o state atualizado.

Dessa forma, evita-se que uma alteração sobrescreva o state produzido por outra operação simultânea.
