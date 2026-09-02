---
marp: true
paginate: true
backgroundColor: '#F5F7FA'
footer: 'DevOps — UniFAAT 2026-2 | Prof. Alexandre Tavares'
style: |
  section {
    font-family: 'Segoe UI', Arial, sans-serif;
    font-size: 17px;
    padding: 35px 48px 28px 48px;
    color: #333333;
  }
  h1 {
    color: #0D2B45;
    border-bottom: 3px solid #F58220;
    padding-bottom: 5px;
    font-size: 1.45em;
    margin-bottom: 8px;
    margin-top: 0;
  }
  h2 { color: #1B3A5C; font-size: 1.2em; margin: 4px 0; }
  h3 { color: #2E86C1; font-size: 0.98em; margin: 4px 0; }
  p, li { margin: 2px 0; line-height: 1.35; }
  ul, ol { margin: 3px 0; padding-left: 18px; }
  strong { color: #F58220; }
  pre { margin: 4px 0; font-size: 0.72em; line-height: 1.25; }
  code { background-color: #e8eef4; color: #1B3A5C; font-size: 0.82em; padding: 1px 4px; }
  pre code { font-size: 1em; padding: 0; }
  table { font-size: 0.82em; width: 100%; margin: 4px 0; border-collapse: collapse; }
  table th { background-color: #1B3A5C; color: white; padding: 3px 7px; }
  table td { padding: 2px 7px; border-bottom: 1px solid #ddd; }
  blockquote { font-size: 0.88em; border-left: 4px solid #F58220; padding-left: 10px; margin: 4px 0; color: #555; }
  section.title {
    background-color: #1B3A5C;
    color: white !important;
    text-align: center;
    justify-content: center;
    padding: 60px;
  }
  section.title h1 { color: #F58220 !important; border-bottom: 3px solid #F58220; font-size: 2.2em; }
  section.title h2 { color: #F58220 !important; font-size: 1.3em; }
  section.title h3 { color: #ccc !important; }
  section.title p { color: #ccc !important; }
  section.title strong { color: #F58220 !important; }
  footer { color: #888; font-size: 0.62em; }
  img { max-height: 340px; display: block; margin: 6px auto; }
---

<!-- _class: title -->

# Aula 04 — VPC, Networking e EC2 na AWS

**DevOps — Centro Universitário UniFAAT**
Prof. Alexandre Tavares | Semestre 2026-2

---

# Por que VPC + EC2?

**Evolução do projeto TechNova:**
- Aula 03: Terraform + IAM na AWS ✅
- **Aula 04: Rede isolada (VPC) + servidor real na nuvem (EC2)**

**O alerta da consultora de segurança:**
> "Vocês estão usando a VPC padrão. Se colocarem um banco de dados ali, ele estará exposto à internet. Precisamos de isolamento de rede."

**O pedido do CTO:**
> "Os investidores querem ver a API rodando em um servidor real, com URL acessível — não no laptop de alguém."

**A ordem da aula:** primeiro a **fundação** (VPC), depois a **casa** (EC2).

> **Fio condutor:** o Spec-Driven continua como método. No Lab 2 você usará o Kiro Spec para provisionar o EC2 na rede que construir.

---

# Objetivos de Aprendizagem

### VPC e Networking
- Compreender o conceito de VPC e isolamento de rede
- Diferenciar subnets públicas e privadas
- Configurar Internet Gateway e Route Tables
- Provisionar uma VPC completa com Terraform

### EC2 Instances
- Conhecer AMIs, instance types, key pairs e security groups
- Provisionar uma instância t2.micro dentro de uma VPC customizada
- Usar User Data para automação e Instance Profile para IAM
- Conectar via SSH e verificar a API na nuvem

---

# O Problema: VPC Padrão Não Oferece Isolamento

Toda conta AWS vem com uma **VPC padrão** — funciona, mas é insegura para produção:

| Aspecto | VPC Padrão | VPC Customizada |
|---------|------------|-----------------|
| Isolamento | Tudo na mesma rede | Segmentação por subnets |
| Exposição | Subnets públicas por padrão | Você escolhe o que é público |
| CIDR | Fixo (172.31.0.0/16) | Você define o bloco de IPs |
| Banco de dados | Exposto à internet | Subnet privada, sem acesso externo |
| Controle | Limitado | Total sobre roteamento e firewalls |

![Rede TechNova](img/redeTechNova.png)

---

# O que é uma VPC?

Uma **VPC** (Virtual Private Cloud) é sua rede privada isolada dentro da AWS — um "data center virtual":

- Você define o **espaço de endereços IP** (CIDR block)
- Cria **subnets** em diferentes Availability Zones
- Controla entrada/saída com **Security Groups** e **NACLs**
- Define **rotas** para o tráfego (Route Tables)

> **Analogia:** VPC é um condomínio fechado. Você decide quantos prédios (subnets) construir, quais têm acesso à rua (públicas) e quais ficam isolados (privadas). O porteiro (Security Group) controla quem entra.

---

# CIDR Notation — Blocos de IP

![IP](img/endIP.png)

| CIDR | IPs Disponíveis | Uso Típico |
|------|----------------|------------|
| `10.0.0.0/16` | 65.536 | VPC inteira |
| `10.0.1.0/24` | 256 | Uma subnet |
| `192.168.0.0/24` | 256 | Rede doméstica |

---

# CIDR — A Máscara e o Design da Rede

**Como funciona a máscara:**
![Mascara IP](img/mascaraIP.png)

**Design da rede TechNova:**
![Arquitetura Rede](img/ArquiteturaRede.png)

---

# Subnets: Pública vs Privada

Uma **subnet** é uma subdivisão da VPC em um bloco menor de IPs, dentro de uma Availability Zone:

![SubNet](img/subnetTechNova.png)

**Subnet pública:** tem rota para o Internet Gateway; instâncias podem ter IP público.
**Subnet privada:** sem rota para o IGW; acesso apenas interno à VPC.

---

# Internet Gateway (IGW)

O **Internet Gateway** conecta sua VPC à internet:

![Internet Gateway](img/igw.png)

- Uma VPC tem **apenas um** IGW
- É **gratuito**
- Sem IGW, nada dentro da VPC acessa a internet

---

# Route Tables (Tabelas de Rotas)

Uma **Route Table** define para onde o tráfego de rede é direcionado:

![Tabela de Rotas](img/tabelaRotas.png)

> A rota `0.0.0.0/0 → igw-xxx` é o que torna uma subnet pública.

---

# NAT Gateway (Conceito)

E se um recurso na subnet **privada** precisar acessar a internet (baixar atualizações) mas **não pode ser acessado** de fora?

**Solução: NAT Gateway**
- Fica na subnet **pública**
- A subnet privada aponta uma rota para ele
- Permite tráfego **de saída** (outbound), bloqueia entrada (inbound)

> **Custo:** NAT Gateway custa ~$32/mês. **NÃO usaremos neste lab** — apenas conhecemos o conceito.

---

# Security Groups vs NACLs

| Característica | Security Group | NACL |
|----------------|---------------|------|
| Nível | Instância (ENI) | Subnet |
| Estado | **Stateful** | Stateless |
| Regras | Apenas ALLOW | ALLOW e DENY |
| Avaliação | Todas as regras | Por ordem numérica |
| Default | Nega tudo (inbound) | Permite tudo |

![Filtro de Rede](img/filtroRede.png)

> Neste curso usamos principalmente **Security Groups** — mais simples e suficientes.

---

# VPC é GRATUITA!

**Sem custo:**
- VPC (ilimitadas por conta)
- Subnets
- Internet Gateway
- Route Tables
- Security Groups e NACLs

**Com custo:**
- NAT Gateway (~$32/mês)
- VPN Gateway
- Elastic IPs não associados
- Tráfego entre AZs (mínimo)

> **No AWS Academy Learner Lab:** todos os recursos de rede desta aula são gratuitos e permitidos.

---

# O que é EC2?

**EC2** (Elastic Compute Cloud) são servidores virtuais sob demanda. Você escolhe SO, hardware e rede — a AWS provisiona em segundos:

![EC2 Instance](img/ec2instance.png)

---

# AMI — Amazon Machine Image

Template pré-configurado com sistema operacional e software base:

| AMI | Sistema | Uso |
|-----|---------|-----|
| Amazon Linux 2023 | Linux (Red Hat) | **Recomendada** — otimizada para AWS |
| Ubuntu 22.04 LTS | Linux (Debian) | Popular, boa documentação |
| Windows Server 2022 | Windows | Aplicações .NET |

> Cada AMI tem um ID diferente por região. Usaremos um **data source** no Terraform para buscar a AMI mais recente automaticamente — nunca fixar o ID.

---

# Instance Types

O **instance type** define o hardware virtual (CPU, memória, rede):

![Instance Type](img/instanceType.png)

| Type | vCPU | RAM | Free Tier |
|------|------|-----|-----------|
| `t2.micro` | 1 | 1 GB | ✅ 750h/mês |
| `t2.small` | 1 | 2 GB | ❌ |
| `t3.medium` | 2 | 4 GB | ❌ |

> Usaremos **sempre `t2.micro`** para manter tudo no Free Tier.

---

# Key Pairs — Acesso SSH

Par de chaves criptográficas para acesso SSH seguro:

![Chave SSH](img/chaveSSH.png)

- A chave privada é baixada **uma única vez**
- Permissões: `chmod 400 key.pem`
- **Nunca versione chaves privadas no Git!**

---

# Security Groups — Firewall Virtual

Controlam o tráfego **para** e **da** instância EC2:

![Security Group](img/securityGroup.png)

> **Menor privilégio:** abra apenas as portas necessárias (ex: 22 para SSH, 3000 para a API), restringindo a origem sempre que possível.

---

# User Data — Automação no Boot

Script que executa automaticamente no **primeiro boot** da instância:

```bash
#!/bin/bash
# Executa como root no primeiro boot
yum update -y
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs git
cd /home/ec2-user
# ... clonar/iniciar a API ...
npm start &
```

- Executa como **root**
- Roda apenas no **primeiro boot** (não em reboots)
- Logs em `/var/log/cloud-init-output.log`

> **No Spec-Driven:** o Kiro pode gerar o `user_data.sh`. Você valida se a API sobe corretamente com `curl`.

---

# Instance Profile — Conectando IAM ao EC2

O **Instance Profile** é como "vestimos" uma IAM Role em um EC2:

![IAM Role](img/iamRoleInstance.png)

> **No AWS Academy Learner Lab:** não é permitido criar IAM Roles. Usaremos o `LabInstanceProfile` (que contém a `LabRole`) já existente — credenciais temporárias sem access keys no código.

---

# Spec-Driven no Lab 2

No Lab Parte 2, você usará o **Kiro Spec** para provisionar o EC2 na VPC:

| Etapa | O que você faz |
|---|---|
| **1. Requisitos** | Descreve o cenário: EC2 t2.micro, subnet pública, SG da API, LabInstanceProfile |
| **2. Design** | Kiro propõe a integração ao `main.tf` existente |
| **3. Tarefas** | Kiro ordena: AMI → key pair → user_data → instância → outputs |
| **4. Código** | Kiro gera; você valida com checklist |

**Checklist de validação:**
- AMI via data source (não ID fixo)
- Usa `LabInstanceProfile` (não cria IAM Role)
- User Data em arquivo separado (`file()`)
- Nenhuma access key hardcoded, tags em tudo

---

# Resumo dos Conceitos

| Conceito | Descrição |
|----------|-----------|
| VPC | Rede virtual privada isolada na AWS |
| CIDR | Notação para blocos de IP |
| Subnet Pública/Privada | Com/sem rota para o Internet Gateway |
| Internet Gateway | Conecta a VPC à internet |
| Route Table | Regras de direcionamento de tráfego |
| Security Group | Firewall stateful (instância) |
| NACL | Firewall stateless (subnet) |
| EC2 / AMI / Instance Type | Servidor virtual / template / hardware |
| Key Pair | Chaves para acesso SSH |
| User Data | Script de automação no primeiro boot |
| Instance Profile | Conecta IAM Role ao EC2 |

---

# Free Tier — Resumo de Custos

| Componente | Custo |
|------------|-------|
| VPC, Subnets, IGW, Route Tables | **Gratuito** (sempre) |
| Security Groups, NACLs | **Gratuito** (sempre) |
| EC2 t2.micro | **Gratuito** (750h/mês, 12 meses) |
| EBS 30 GB gp2 | **Gratuito** (12 meses) |
| NAT Gateway | ⚠️ ~$32/mês (**NÃO usar no lab**) |

> **Sempre execute `terraform destroy`** após o Lab Parte 2 para manter o ambiente limpo.

---

# Referências e Próximos Passos

**Referências:**
- Amazon VPC — [docs.aws.amazon.com/vpc](https://docs.aws.amazon.com/vpc)
- Amazon EC2 — [docs.aws.amazon.com/ec2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide)
- Terraform AWS Provider — [registry.terraform.io/providers/hashicorp/aws](https://registry.terraform.io/providers/hashicorp/aws)
- AWS Academy Learner Lab (ambiente da disciplina)

**Para a próxima aula:**
- Completar o TF desta aula (portfólio + PR + execução no AWS Academy)
- Estudar o `TA.md` da Aula 05
- Executar `terraform destroy` em todos os recursos

**Próxima aula:**
**Aula 05 — RDS e Remote State**
Banco de dados gerenciado + estado remoto com S3 e DynamoDB.
