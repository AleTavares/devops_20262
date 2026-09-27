# Entrega — Aula 06: Terraform Modules

**Aluno:** José Henrique Teixeira Luiz
**RA:** 3225002
**Data:** 24/09/2026

## Repositório

- URL: https://github.com/zzin742/unifaat-devops-portfolio
- Pasta do trabalho: [`aula-06/`](https://github.com/zzin742/unifaat-devops-portfolio/tree/main/aula-06)

## Evidências

- [x] Módulo VPC com `for_each` para subnets dinâmicas
- [x] Módulo Security Group genérico (regras como lista de objetos)
- [x] Módulo EC2 reutilizável
- [x] Módulo RDS reutilizável
- [x] Composição entre módulos (output de um alimenta input de outro)
- [x] Dois ambientes (dev + staging) usando os mesmos módulos
- [x] `terraform validate` e `terraform plan` sem erros nos dois ambientes
- [x] README documentando cada módulo (inputs, outputs, exemplo)

### Detalhe das evidências

**`for_each` no módulo VPC** — as subnets vêm de um `map(object({cidr, az, type}))`,
não de listas indexadas. O endereço de cada recurso é a chave do mapa
(`aws_subnet.esta["private-1a"]`), então remover uma subnet do meio não renumera
nem recria as outras.

**Security Group genérico** — um único módulo, instanciado duas vezes. As regras
entram como lista de objetos e cada uma libera **por CIDR** ou **por Security
Group de origem**; uma `validation` recusa a regra que informe os dois ou nenhum.

**Composição entre módulos** — o caso que mais importa é o `rds_sg`, que recebe
`module.api_sg.sg_id`: a regra da porta 5432 não cita CIDR nenhum, ela autoriza o
Security Group da aplicação. Nenhum `depends_on` é escrito à mão; a ordem de
criação vem do grafo de dependências.

**Dois ambientes com os mesmos módulos** — `environments/dev/main.tf` e
`environments/staging/main.tf` são **byte a byte idênticos**:

```
$ diff environments/dev/main.tf environments/staging/main.tf
$ echo $?
0
```

Toda a diferença entre os ambientes cabe no `terraform.tfvars`:

| Aspecto | dev | staging |
|---|---|---|
| VPC CIDR | 10.0.0.0/16 | 10.1.0.0/16 |
| Subnets públicas | 10.0.1.0/24, 10.0.2.0/24 | 10.1.1.0/24, 10.1.2.0/24 |
| Subnets privadas | 10.0.3.0/24, 10.0.4.0/24 | 10.1.3.0/24, 10.1.4.0/24 |
| DB Name | technova_dev | technova_staging |
| Naming | technova-dev-* | technova-staging-* |

## Evidência do terraform plan

Rodado no **AWS Academy Learner Lab**, conta `447916381827`, região `us-east-1`.
Arquivo completo em
[`aula-06/evidencias/terraform-plan.txt`](https://github.com/zzin742/unifaat-devops-portfolio/blob/main/aula-06/evidencias/terraform-plan.txt).

```
AMBIENTE: dev
Plan: 21 to add, 0 to change, 0 to destroy.

AMBIENTE: staging
Plan: 21 to add, 0 to change, 0 to destroy.

Conferencia de seguranca (identica nos dois ambientes):
  IAM a criar:             0  (o Learner Lab nega iam:CreateRole)
  publicly_accessible:     false
  storage_encrypted:       true
  http_tokens (IMDSv2):    "required"
  regra 5432 por SG:       1 regra(s) - origem = SG da API, nenhum CIDR
  senha no plan:           0 ocorrencias em texto claro
```

Os dois ambientes planejam o mesmo número de recursos a partir do mesmo código.

> **Um erro que só o `plan` pegou.** O `terraform validate` passava, mas o
> `plan` falhava com `Invalid for_each argument` no módulo `security-group`: a
> chave do `for_each` continha o `source_security_group_id`, que só existe depois
> do apply, e o filtro testava esse mesmo ID contra `null` — o que torna o mapa
> inteiro indeterminado em tempo de plan. A correção foi usar a `description`
> como chave e filtrar por `cidr_blocks`, que são estáticos. Vale registrar
> porque é a diferença prática entre `validate` (sintaxe e tipos) e `plan`
> (o grafo resolvido de verdade).

### terraform validate — os dois ambientes

Arquivo completo em
[`aula-06/evidencias/terraform-validate.txt`](https://github.com/zzin742/unifaat-devops-portfolio/blob/main/aula-06/evidencias/terraform-validate.txt).

```
$ terraform fmt -recursive -check
(nenhum arquivo listado = tudo formatado)

AMBIENTE: dev
$ terraform validate
Success! The configuration is valid.

AMBIENTE: staging
$ terraform validate
Success! The configuration is valid.
```
