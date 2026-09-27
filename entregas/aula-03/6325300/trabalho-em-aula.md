# Trabalho em Aula - Aula 03: Terraform e Seguranca AWS

**Aluno:** Gabriel Carneiro da Silva
**RA:** 6325300
**Data:** 02/09/2026

## Parte 1 - Analise de Riscos: Infraestrutura Manual

### Riscos e solucoes com Terraform

| # | Risco (infraestrutura manual) | Como Terraform resolve |
|---|---|---|
| 1 | Infraestrutura sem documentacao clara, criada por cliques no Console AWS | Os arquivos `.tf` documentam exatamente quais recursos devem existir |
| 2 | Dificuldade para recriar ambientes iguais, como staging e producao | O mesmo codigo pode ser aplicado em outro ambiente com variaveis diferentes |
| 3 | Mudancas sem historico, dificultando auditoria e investigacao | O Git registra quem alterou, quando alterou e por que alterou |
| 4 | Erro humano em configuracoes sensiveis, como liberar acesso publico ou porta errada | O Terraform permite revisar o `plan` antes de aplicar qualquer mudanca |
| 5 | Crescimento da equipe aumenta risco de permissoes inconsistentes | Users, groups, roles e policies ficam padronizados como codigo |
| 6 | Recursos deletados manualmente podem ser dificeis de reconstruir | O Terraform permite detectar drift e recriar a infraestrutura declarada |

## Parte 2 - Auditoria de Seguranca: Design de IAM

### Estrutura IAM proposta

```text
AWS Account Root (NUNCA usar diretamente)
|
|-- Group: technova-billing-readers
|   |-- Users: Carlos Mendes
|   |-- Policy: billing-read-only
|       |-- Acoes: visualizar billing e relatorios de custo
|
|-- Group: technova-developers
|   |-- Users: Juliana Santos, Rafael Oliveira
|   |-- Policy: developers-s3-read-write
|       |-- Acoes: ler/escrever S3 da TechNova e descrever EC2
|
|-- Group: technova-platform-eng
|   |-- Users: Rafael Oliveira
|   |-- Policy: platform-ec2-s3-vpc-read-iam-read
|       |-- Acoes: gerenciar EC2, S3, VPC e consultar IAM
|
|-- Group: technova-interns
|   |-- Users: Lucas
|   |-- Policy: interns-read-only
|       |-- Acoes: somente visualizar S3, sem escrita e sem delete
|
|-- Role: technova-ec2-s3-role
    |-- Trust Policy: servico EC2 pode assumir
    |-- Permissions: ler/escrever no bucket technova-app-data
```

### Explicacao do design

- O root deve ser usado apenas para tarefas administrativas raras, protegido por MFA.
- Cada pessoa deve ter seu proprio user IAM, sem compartilhar senha ou access key.
- Groups separam responsabilidades por papel: billing, development, platform e interns.
- Policies customizadas evitam permissoes amplas demais.
- A API TechNova em EC2 deve usar role, nao access key fixa dentro do codigo.

### Violacoes de menor privilegio com Managed Policies

1. Dar `AmazonS3FullAccess` para Lucas violaria menor privilegio, porque ele precisa apenas visualizar S3. Com essa policy, ele poderia criar, alterar ou excluir buckets e objetos.

2. Dar `AdministratorAccess` ou permissoes amplas de EC2 para Juliana tambem violaria menor privilegio. Ela precisa desenvolver e consultar recursos, mas nao precisa encerrar instancias ou alterar IAM.

3. Usar uma unica access key root para todos seria ainda pior: qualquer vazamento permitiria excluir recursos, criar custos altos e acessar dados sensiveis sem rastreabilidade individual.

### Exemplo de protecao por menor privilegio

Se a credencial do estagiario vazar, uma policy somente leitura limita o impacto.
O atacante conseguiria visualizar alguns recursos autorizados, mas nao conseguiria deletar buckets, encerrar EC2 ou alterar permissoes IAM.
