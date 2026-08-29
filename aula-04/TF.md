# Trabalho de Fixação (TF) — Aula 04: Terraform VPC + EC2 Multi-AZ

## Desafio

Crie uma infraestrutura VPC + EC2 Multi-AZ completa para a TechNova usando Terraform, demonstrando domínio de networking AWS (VPC, subnets, IGW, Route Tables, Security Groups) e provisionamento de instâncias com User Data. Publique via Pull Request no repositório da disciplina.

---

## Informações de Entrega

| Item | Detalhe |
|------|---------|
| **Prazo** | 1 semana a partir da data da aula |
| **Forma de entrega** | Pull Request (PR) para o repositório da disciplina |
| **Pasta de entrega no fork** | `entregas/aula-04/RA/` (substitua RA pelo seu número de matrícula) |
| **Conteúdo do PR** | Apenas o arquivo `entrega.md` com link do repositório + evidências |
| **Arquivos do projeto** | No repositório `unifaat-devops-portfolio`, pasta `aula-04/` |
| **Execução do Lab** | Realizada no **AWS Academy Learner Lab** — o professor confere a nota e o percentual de execução |

> **Avaliação no AWS Academy:** Além do código entregue via PR, o professor verifica no **AWS Academy** a **nota** e o **percentual de execução** do seu laboratório. Execute o Lab completo no ambiente do Academy — a atividade prática no Learner Lab faz parte da avaliação do TF.

### Como Entregar via Pull Request

1. Faça um **fork** do repositório da disciplina (se ainda não fez)
2. Clone o seu fork localmente
3. Crie a pasta `entregas/aula-04/SEU-RA/`
4. Adicione **apenas** o arquivo `entrega.md` (modelo abaixo) — os arquivos do projeto ficam no `unifaat-devops-portfolio`
5. Faça commit e push para o seu fork
6. Abra um **Pull Request** para o repositório original

**Modelo do arquivo `entrega.md`:**

```markdown
# Entrega — Aula 04: VPC + EC2 Multi-AZ

**Aluno:** [Seu nome completo]  
**RA:** [Seu RA]  
**Data:** [Data da entrega]

## Repositório

- URL: https://github.com/SEU-USUARIO/unifaat-devops-portfolio

## Evidências

- [ ] VPC com 4 subnets (2 públicas + 2 privadas) em 2 AZs
- [ ] Internet Gateway + Route Tables configurados
- [ ] Security Groups com menor privilégio
- [ ] EC2 t2.micro com User Data (API rodando)
- [ ] Instance Profile com IAM Role
- [ ] Tags em todos os recursos
- [ ] `terraform-plan-output.txt` com evidência do plano
- [ ] README com diagrama da arquitetura
- [ ] `terraform destroy` executado após evidências

## Evidência da API Rodando

[Cole aqui o output do curl ou screenshot]
```

---

## Contexto

A equipe de Platform Engineering da TechNova ficou impressionada com seu trabalho no lab.
 Agora eles querem a versão "de verdade" — uma infraestrutura preparada para **alta disponibilidade** com múltiplas Availability Zones, pronta para receber um Load Balancer no futuro.

Sua missão: criar uma infraestrutura VPC + EC2 mais robusta que o lab, com subnets distribuídas em múltiplas AZs e todos os recursos devidamente tagueados.

---

## Exercício: Infraestrutura Multi-AZ Completa

### Requisitos Obrigatórios

Crie com Terraform toda a infraestrutura descrita abaixo:

#### 1. VPC

- CIDR: `10.0.0.0/16`
- DNS support e DNS hostnames habilitados
- Tag: `Name = "technova-vpc"`

#### 2. Subnets — 4 no total, em 2 AZs diferentes

![SubNet](img/tfVPCSubNet.png)

- 2 subnets públicas (em AZs diferentes): `10.0.1.0/24` e `10.0.3.0/24`
- 2 subnets privadas (em AZs diferentes): `10.0.2.0/24` e `10.0.4.0/24`
- `map_public_ip_on_launch = true` apenas nas públicas

#### 3. Internet Gateway + Route Tables

- 1 Internet Gateway anexado à VPC
- 1 Route Table pública com rota `0.0.0.0/0 → IGW`
- Associar a Route Table pública às **duas** subnets públicas
- Subnets privadas usam a Route Table padrão (sem rota para internet)

#### 4. Security Groups

**Security Group da API:**
- Porta `22` (TCP) — SSH — de `0.0.0.0/0`
- Porta `3000` (TCP) — API Node.js — de `0.0.0.0/0`
- Egress: todo tráfego permitido

**Security Group do banco de dados (futuro):**
- Porta `5432` (TCP) — PostgreSQL — apenas de `10.0.0.0/16` (VPC interna)
- Egress: todo tráfego permitido

#### 5. EC2 Instance

- Tipo: `t2.micro` (Free Tier!)
- AMI: Amazon Linux 2023 (via data source)
- Subnet: uma das subnets **públicas**
- Security Group: API SG
- Key Pair: criar via Terraform
- User Data que faz:
  1. Instala Node.js 18
  2. Instala Git
  3. Clona o repositório `technova-api` (pode usar a versão simplificada do lab)
  4. Executa `npm install`
  5. Inicia a aplicação na porta 3000

#### 6. Instance Profile

- IAM Role com permissão `AmazonS3ReadOnlyAccess`
- Instance Profile anexado ao EC2
- Trust policy para `ec2.amazonaws.com`

#### 7. Tags em TODOS os recursos

Todos os recursos devem ter as seguintes tags:

```hcl
tags = {
  Name        = "technova-<nome-do-recurso>"
  Project     = "TechNova"
  Environment = "development"
  ManagedBy   = "Terraform"
  Owner       = "<seu-RA>"
}
```

#### 8. Outputs

Exporte os seguintes valores:

- `vpc_id` — ID da VPC
- `public_subnet_ids` — Lista com IDs das subnets públicas
- `private_subnet_ids` — Lista com IDs das subnets privadas
- `api_security_group_id` — ID do SG da API
- `db_security_group_id` — ID do SG do banco
- `ec2_public_ip` — IP público da instância EC2
- `api_url` — URL completa da API (`http://<ip>:3000`)
- `ssh_command` — Comando SSH para conectar

---

## Evidências de Funcionamento

Após aplicar o Terraform e verificar que tudo funciona, capture as seguintes evidências:

### Evidência 1: Output do `terraform plan`

```bash
terraform plan > evidencia-plan.txt
```

### Evidência 2: Resposta da API via curl

```bash
curl http://<IP_PUBLICO>:3000 > evidencia-api.json
curl http://<IP_PUBLICO>:3000/health >> evidencia-api.json
```

### Evidência 3: Screenshot ou output do SSH

```bash
ssh -i ~/.ssh/technova-key ec2-user@<IP> "node --version && aws sts get-caller-identity" > evidencia-ssh.txt
```

> **⚠️ IMPORTANTE:** Após capturar as evidências, execute `terraform destroy` para limpar todos os recursos e evitar custos!

---

## README.md Obrigatório

Seu README deve conter:

1. **Título:** "Infraestrutura TechNova — Aula 04"
2. **Diagrama da arquitetura** (pode ser ASCII art como o modelo acima)
3. **Como usar:**
   - Pré-requisitos (AWS CLI, Terraform, chave SSH)
   - Comandos para executar (`terraform init`, `plan`, `apply`)
   - Como testar (curl, SSH)
   - Como destruir (`terraform destroy`)
4. **Decisões técnicas:** explique brevemente por que usou Multi-AZ, por que separou público/privado, etc.
5. **Recursos criados:** tabela com nome e função de cada recurso

---

## Critérios de Avaliação

| Critério | Peso | Descrição |
|----------|------|-----------|
| **Execução no AWS Academy** | **20%** | Nota e percentual de execução do laboratório conferidos pelo professor no AWS Academy |
| Infraestrutura funcional | 25% | `terraform apply` cria tudo sem erros, API acessível |
| Arquitetura Multi-AZ | 10% | 4 subnets em 2 AZs, design correto |
| Security Groups | 15% | Princípio do menor privilégio aplicado corretamente |
| User Data + EC2 | 10% | API inicia automaticamente, Instance Profile funciona |
| Tags e organização | 10% | Todos os recursos tagueados, código organizado |
| Evidências | 5% | plan, curl e SSH documentados |
| README com diagrama | 5% | Documentação clara com arquitetura visual |

---

## Dicas

- Use o código do lab como base — adicione as subnets/AZs extras
- Para criar múltiplas subnets, considere usar variáveis do tipo `list` ou `map`
- Teste com `terraform plan` antes de `apply` — evite surpresas
- Se algo der errado, `terraform destroy` e comece de novo
- Lembre-se: **t2.micro** SEMPRE para manter no Free Tier
- Verifique o `.gitignore` antes do commit — nada de `.tfstate` ou `.pem` no repo!

---

## Entrega

### 1 — Publicar no portfólio

```bash
cd unifaat-devops-portfolio
git checkout -b feature/aula-04-vpc-ec2
# ... desenvolva os arquivos .tf em aula-04/ ...
git add aula-04/
git commit -m "feat(aula-04): VPC + EC2 Multi-AZ com Terraform"
git checkout main
git merge feature/aula-04-vpc-ec2
git push origin main
git push origin feature/aula-04-vpc-ec2
```

### 2 — Registrar entrega no fork da disciplina

```bash
cd /caminho/para/seu-fork-da-disciplina
git checkout -b entregas/aula-04/SEU-RA
mkdir -p entregas/aula-04/SEU-RA
# Crie o arquivo entrega.md (modelo na seção Informações de Entrega)
git add entregas/aula-04/SEU-RA/entrega.md
git commit -m "feat(aula-04): entrega TF - SEU NOME (RA: SEU-RA)"
git push -u origin entregas/aula-04/SEU-RA
```

Abra o Pull Request no GitHub com:
- **Título:** `[Aula 04] RA: SEU-RA - SEU NOME`
- **Base:** `main`
- **Compare:** `entregas/aula-04/SEU-RA`

> **⚠️ Lembrete final:** Execute `terraform destroy` ANTES de fazer o PR. As evidências provam que funcionou. Não deixe recursos rodando na AWS!
