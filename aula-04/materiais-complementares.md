# Materiais Complementares | Aula 04

## VPC e Networking

### Documentação Oficial AWS

- [O que é Amazon VPC?](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html) — visão geral completa do serviço
- [VPCs e Subnets](https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html) — configuração de subnets públicas e privadas
- [Internet Gateways](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html) — como funciona o IGW
- [Route Tables](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html) — regras de roteamento
- [NAT Gateways](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html) — acesso à internet para subnets privadas
- [Network ACLs](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html) — firewalls stateless no nível de subnet
- [Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html) — firewalls stateful para instâncias
- [VPC Pricing](https://aws.amazon.com/vpc/pricing/) — detalhamento de custos (VPC é gratuita, NAT Gateway não)

### Documentação Terraform — VPC

- [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) — recurso VPC
- [aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) — recurso Subnet
- [aws_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) — recurso IGW
- [aws_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) — recurso Route Table
- [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) — recurso Security Group
- [aws_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) — associação RT-Subnet

---

## EC2 Instances

### Documentação Oficial AWS

- [O que é Amazon EC2?](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html) — visão geral do serviço
- [Instance Types](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html) — famílias e tamanhos de instância
- [Amazon Machine Images (AMI)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html) — templates de SO
- [Key Pairs e SSH](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) — acesso via chave
- [User Data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html) — scripts de bootstrap
- [Security Groups para EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-security-groups.html) — regras de firewall
- [Instance Profiles (IAM Roles)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html) — associar Role ao EC2
- [EC2 Free Tier](https://aws.amazon.com/free/) — limites gratuitos (t2.micro, 750h/mês)

### Documentação Terraform — EC2

- [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) — recurso EC2
- [aws_key_pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) — recurso Key Pair
- [aws_ami (data source)](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) — buscar AMIs
- [aws_iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) — Instance Profile

---

## Vídeos em Português

- [AWS VPC - Do Zero ao Avançado](https://www.youtube.com/results?search_query=aws+vpc+tutorial+portugues) — buscar tutoriais atualizados sobre VPC
- [Linuxtips — AWS VPC na Prática](https://www.youtube.com/c/LinuxTips) — canal com conteúdo DevOps em PT-BR
- [Full Cycle — Terraform + AWS](https://www.youtube.com/@FullCycle) — canal com conteúdo de IaC
- [AWS em Português (canal oficial)](https://www.youtube.com/@AWSPortugues) — conteúdo oficial da AWS em PT-BR

---

## Vídeos em Inglês

- [AWS re:Invent — VPC Deep Dive](https://www.youtube.com/results?search_query=aws+reinvent+vpc+deep+dive) — palestras técnicas aprofundadas
- [freeCodeCamp — AWS VPC Tutorial](https://www.youtube.com/results?search_query=freecodecamp+aws+vpc) — tutorial completo e gratuito
- [TechWorld with Nana — AWS Networking](https://www.youtube.com/@TechWorldwithNana) — excelente canal DevOps
- [Stephane Maarek — AWS EC2 Fundamentals](https://www.youtube.com/@StephaneMaarek) — instrutor reconhecido AWS

---

## Cheat Sheets e Referências Rápidas

### CIDR Calculator

- [CIDR.xyz](https://cidr.xyz/) — calculadora visual interativa de CIDR
- [IP Address Guide — CIDR Chart](https://www.ipaddressguide.com/cidr) — tabela de referência rápida

### Security Group Rules — Referência

| Serviço | Porta | Protocolo | Uso |
|---------|-------|-----------|-----|
| SSH | 22 | TCP | Acesso remoto ao servidor |
| HTTP | 80 | TCP | Web server (sem SSL) |
| HTTPS | 443 | TCP | Web server (com SSL) |
| Node.js (dev) | 3000 | TCP | API Express em desenvolvimento |
| PostgreSQL | 5432 | TCP | Banco de dados |
| MySQL | 3306 | TCP | Banco de dados |
| Redis | 6379 | TCP | Cache/sessões |
| ICMP (ping) | -1 | ICMP | Diagnóstico de rede |

### Instance Types — Free Tier

| Type | vCPU | RAM | Rede | Free Tier |
|------|------|-----|------|-----------|
| t2.micro | 1 | 1 GB | Low to Moderate | ✅ 750h/mês |
| t2.small | 1 | 2 GB | Low to Moderate | ❌ |
| t2.medium | 2 | 4 GB | Low to Moderate | ❌ |
| t3.micro | 2 | 1 GB | Up to 5 Gbps | ✅ (em algumas regiões) |

---

## Ferramentas Úteis

### Clientes SSH

- **Linux/macOS:** Terminal nativo (`ssh` já instalado)
- **Windows:** [PuTTY](https://www.putty.org/) ou Windows Terminal com OpenSSH
- **Multi-plataforma:** [Termius](https://termius.com/) — app de SSH moderno

### Diagnóstico de Rede

- **AWS VPC Reachability Analyzer** — [Documentação](https://docs.aws.amazon.com/vpc/latest/reachability/what-is-reachability-analyzer.html) — ferramenta da AWS para diagnosticar problemas de conectividade entre recursos
- **nmap** — scanner de portas para verificar se o Security Group está correto
- **telnet** — testar conectividade em portas específicas: `telnet <IP> 3000`
- **traceroute** — rastrear rota de rede: `traceroute <IP>`

### Extensões VS Code

- [HashiCorp Terraform](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform) — syntax highlighting, autocomplete, format
- [AWS Toolkit](https://marketplace.visualstudio.com/items?itemName=AmazonWebServices.aws-toolkit-vscode) — integração com AWS
- [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) — editar arquivos diretamente na instância EC2

---

## Artigos e Blog Posts

### Boas Práticas de Networking AWS

- [AWS Well-Architected — Networking Pillar](https://docs.aws.amazon.com/wellarchitected/latest/framework/sec-network.html) — recomendações oficiais de segurança de rede
- [AWS VPC Design Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html) — padrões recomendados pela AWS
- [Multi-AZ Architecture](https://docs.aws.amazon.com/whitepapers/latest/real-time-communication-on-aws/high-availability-and-scalability-on-aws.html) — por que distribuir em múltiplas AZs

### EC2 Best Practices

- [EC2 Best Practices](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-best-practices.html) — guia oficial da AWS
- [User Data Best Practices](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html) — como escrever scripts de inicialização confiáveis
- [Instance Metadata Service](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html) — acessar informações da instância de dentro dela

---

## ⚠️ Lembretes Importantes sobre Free Tier

### O que é GRATUITO (sem limite de tempo):
- VPC, Subnets, Internet Gateway, Route Tables
- Security Groups, NACLs
- IAM (users, groups, roles, policies)

### O que é GRATUITO (12 meses após criar a conta):
- EC2 t2.micro: 750 horas/mês
- EBS gp2: 30 GB
- Transferência de dados: 100 GB/mês (saída)

### O que NÃO é gratuito (evitar!):
- ❌ NAT Gateway (~$32/mês) — **NÃO criar nos labs**
- ❌ Elastic IP não associado ($0.005/hora)
- ❌ EC2 t2.small ou maior
- ❌ EBS provisioned IOPS (io1/io2)
- ❌ AWS VPN/DirectConnect

### Dica de ouro:
```bash
# Sempre ao final do lab:
terraform destroy

# Verificar que não ficou nada:
aws ec2 describe-instances --query "Reservations[].Instances[?State.Name=='running'].InstanceId" --output text
aws ec2 describe-vpcs --query "Vpcs[?IsDefault==\`false\`].VpcId" --output text
```

---

## Próxima Aula

Na **Aula 05**, vamos evoluir essa infraestrutura com:
- Load Balancer (ALB) para distribuir tráfego
- Auto Scaling Group para alta disponibilidade
- Multi-AZ deployment para resiliência
- A arquitetura Multi-AZ deste TF será a base!
