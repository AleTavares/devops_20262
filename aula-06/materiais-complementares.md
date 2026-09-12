# Aula 06 — Materiais Complementares

## Documentação Oficial

### Terraform Modules

| Recurso | Link | Descrição |
|---------|------|-----------|
| Creating Modules | [developer.hashicorp.com/terraform/language/modules/develop](https://developer.hashicorp.com/terraform/language/modules/develop) | Guia oficial para criar módulos |
| Module Sources | [developer.hashicorp.com/terraform/language/modules/sources](https://developer.hashicorp.com/terraform/language/modules/sources) | Todas as formas de referenciar módulos (local, Git, Registry, S3) |
| Module Composition | [developer.hashicorp.com/terraform/language/modules/develop/composition](https://developer.hashicorp.com/terraform/language/modules/develop/composition) | Padrões de composição entre módulos |
| Input Variables | [developer.hashicorp.com/terraform/language/values/variables](https://developer.hashicorp.com/terraform/language/values/variables) | Declaração e uso de variáveis |
| Output Values | [developer.hashicorp.com/terraform/language/values/outputs](https://developer.hashicorp.com/terraform/language/values/outputs) | Declaração e exposição de outputs |
| for_each Meta-Argument | [developer.hashicorp.com/terraform/language/meta-arguments/for_each](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each) | Criação dinâmica de recursos com for_each |
| count Meta-Argument | [developer.hashicorp.com/terraform/language/meta-arguments/count](https://developer.hashicorp.com/terraform/language/meta-arguments/count) | Criação de múltiplos recursos com count |
| terraform_remote_state | [developer.hashicorp.com/terraform/language/state/remote-state-data](https://developer.hashicorp.com/terraform/language/state/remote-state-data) | Leitura de state remoto como data source |

### Terraform Registry

| Recurso | Link | Descrição |
|---------|------|-----------|
| Terraform Registry | [registry.terraform.io](https://registry.terraform.io/) | Repositório oficial de módulos |
| terraform-aws-modules/vpc/aws | [registry.terraform.io/modules/terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) | Módulo VPC mais popular (50M+ downloads) |
| terraform-aws-modules/ec2-instance/aws | [registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws](https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest) | Módulo EC2 da comunidade |
| terraform-aws-modules/rds/aws | [registry.terraform.io/modules/terraform-aws-modules/rds/aws](https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest) | Módulo RDS da comunidade |
| terraform-aws-modules/security-group/aws | [registry.terraform.io/modules/terraform-aws-modules/security-group/aws](https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest) | Módulo Security Group com regras predefinidas |
| Publishing Modules | [developer.hashicorp.com/terraform/registry/modules/publish](https://developer.hashicorp.com/terraform/registry/modules/publish) | Como publicar seus próprios módulos no Registry |

---

## Vídeos Recomendados

### Em Português

| Vídeo | Canal | Duração | Conteúdo |
|-------|-------|---------|----------|
| Terraform Modules - Conceito e Prática | Fabricio Veronez | ~20 min | Introdução a módulos com exemplo prático |
| Terraform for_each e count | Chandra Lingam (legendado) | ~15 min | Diferenças entre count e for_each |
| Terraform Registry - Usando módulos prontos | LinuxTips | ~25 min | Como usar módulos do Registry |

### Em Inglês

| Vídeo | Canal | Duração | Conteúdo |
|-------|-------|---------|----------|
| Terraform Modules Deep Dive | HashiCorp | ~45 min | Módulos do básico ao avançado |
| Terraform Module Patterns | Ned Bellavance | ~30 min | Padrões de design para módulos |
| Terraform for_each vs count | Spacelift | ~12 min | Comparação prática com exemplos |
| Building Reusable Terraform Modules | DevOps Directive | ~40 min | Construindo módulos production-ready |
| Terraform Module Composition | Anton Babenko | ~35 min | Composição avançada de módulos |

---

## Artigos e Blog Posts

### Fundamentals

| Artigo | Autor/Fonte | Tópico |
|--------|-------------|--------|
| [Terraform Best Practices — Module](https://www.terraform-best-practices.com/key-concepts#module) | Anton Babenko | Boas práticas para organização de módulos |
| [When to Use Terraform Modules](https://developer.hashicorp.com/terraform/tutorials/modules/module) | HashiCorp Learn | Tutorial oficial: quando e como modularizar |
| [Terraform Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure) | HashiCorp | Estrutura recomendada de diretórios |

### Advanced Patterns

| Artigo | Autor/Fonte | Tópico |
|--------|-------------|--------|
| [Terraform for_each Examples](https://spacelift.io/blog/terraform-for-each) | Spacelift | Exemplos práticos de for_each |
| [count vs for_each](https://spacelift.io/blog/terraform-count-vs-for-each) | Spacelift | Comparação detalhada com cenários |
| [Module Composition Design Patterns](https://developer.hashicorp.com/terraform/language/modules/develop/composition) | HashiCorp | Padrões oficiais de composição |
| [Terraform Remote State Data Source](https://spacelift.io/blog/terraform-remote-state) | Spacelift | Como usar terraform_remote_state |
| [Terraform Module Versioning](https://developer.hashicorp.com/terraform/language/modules/sources#selecting-a-revision) | HashiCorp | Versionamento com Git tags e constraints |

### Production Best Practices

| Artigo | Autor/Fonte | Tópico |
|--------|-------------|--------|
| [How to Create Terraform Modules](https://blog.gruntwork.io/how-to-create-reusable-infrastructure-with-terraform-modules-25526d65f73d) | Gruntwork | Guia completo para módulos production-ready |
| [Terraform Module Testing](https://developer.hashicorp.com/terraform/language/tests) | HashiCorp | Framework de testes para módulos |
| [Module Design: Thin vs Thick Modules](https://www.hashicorp.com/blog/terraform-modules-at-scale) | HashiCorp Blog | Design decisions para módulos em escala |

---

## Ferramentas Úteis

| Ferramenta | Link | Descrição |
|------------|------|-----------|
| terraform-docs | [github.com/terraform-docs/terraform-docs](https://github.com/terraform-docs/terraform-docs) | Gera documentação automática de módulos (inputs, outputs, providers) |
| tflint | [github.com/terraform-linters/tflint](https://github.com/terraform-linters/tflint) | Linter para Terraform — detecta erros e bad practices |
| Checkov | [github.com/bridgecrewio/checkov](https://github.com/bridgecrewio/checkov) | Scanner de segurança para IaC (Terraform, CloudFormation) |
| Terratest | [github.com/gruntwork-io/terratest](https://github.com/gruntwork-io/terratest) | Framework Go para testes de infraestrutura |
| Infracost | [github.com/infracost/infracost](https://github.com/infracost/infracost) | Estimativa de custos para mudanças no Terraform |

### terraform-docs — Exemplo de uso

```bash
# Instalar terraform-docs
brew install terraform-docs  # macOS
# ou download: https://github.com/terraform-docs/terraform-docs/releases

# Gerar documentação para um módulo
cd modules/vpc
terraform-docs markdown table . > README.md

# Saída gerada automaticamente:
# | Name | Description | Type | Default | Required |
# |------|-------------|------|---------|----------|
# | vpc_cidr | CIDR block da VPC | string | n/a | yes |
# | ...
```

---

## Exercícios Extras (Para Quem Quer Ir Além)

### Exercício 1: Módulo com Conditional Resources

Crie um módulo VPC que opcionalmente cria um NAT Gateway:

```hcl
variable "enable_nat_gateway" {
  type    = bool
  default = false
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? 1 : 0
  # ...
}
```

### Exercício 2: Módulo com Dynamic Blocks

Refatore o módulo de Security Group para usar `dynamic` blocks:

```hcl
resource "aws_security_group" "this" {
  # ...

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }
}
```

### Exercício 3: Múltiplos Ambientes com for_each no Module

Use `for_each` no bloco `module` para criar múltiplos ambientes:

```hcl
locals {
  environments = {
    dev     = { cidr = "10.0.0.0/16", instance_type = "t2.micro" }
    staging = { cidr = "10.1.0.0/16", instance_type = "t2.micro" }
    prod    = { cidr = "10.2.0.0/16", instance_type = "t3.small" }
  }
}

module "vpc" {
  for_each = local.environments
  source   = "./modules/vpc"

  vpc_cidr     = each.value.cidr
  environment  = each.key
  project_name = "technova"
}
```

### Exercício 4: terraform-docs Automation

Configure terraform-docs para gerar documentação automaticamente via pre-commit hook:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/terraform-docs/terraform-docs
    rev: "v0.17.0"
    hooks:
      - id: terraform-docs-go
        args: ["markdown", "table", "--output-file", "README.md"]
```

### Exercício 5: Module Testing com terraform test

Crie um teste básico para o módulo VPC usando o framework nativo:

```hcl
# modules/vpc/tests/vpc_basic.tftest.hcl

run "create_vpc" {
  command = plan

  variables {
    vpc_cidr     = "10.0.0.0/16"
    project_name = "test"
    environment  = "test"
    subnets = {
      "public-1" = { cidr = "10.0.1.0/24", az = "us-east-1a", type = "public" }
    }
  }

  assert {
    condition     = aws_vpc.main.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR incorreto"
  }
}
```

---

## Referências Rápidas

### Cheat Sheet — Módulos

```hcl
# Módulo local
module "vpc" {
  source = "./modules/vpc"
}

# Módulo do Registry
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
}

# Módulo Git com tag
module "vpc" {
  source = "git::https://github.com/org/repo.git//modules/vpc?ref=v1.0.0"
}

# Módulo S3
module "vpc" {
  source = "s3::https://s3-us-east-1.amazonaws.com/bucket/vpc.zip"
}
```

### Cheat Sheet — for_each

```hcl
# for_each com map
resource "aws_subnet" "this" {
  for_each   = var.subnets
  cidr_block = each.value.cidr
}

# for_each com set
resource "aws_iam_user" "this" {
  for_each = toset(["alice", "bob", "carol"])
  name     = each.key
}

# Filtrar com for expression
locals {
  public_only = {
    for k, v in var.subnets : k => v if v.type == "public"
  }
}
```

### Cheat Sheet — Outputs entre Módulos

```hcl
# Módulo A expõe
output "vpc_id" { value = aws_vpc.main.id }

# Módulo B consome
module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id  # module.<name>.<output_name>
}
```
