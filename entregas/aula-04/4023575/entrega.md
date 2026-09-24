# Entrega — Aula 04: VPC + EC2 Multi-AZ

**Aluno:** Emilly Santos de Oliveira  
**RA:** 4023575  
**Data:** 10/09/2026

## Repositório

- URL: https://github.com/leonidas-alt/unifaat-devops-portfolio.git

## Evidências

- [x] VPC criada (10.0.0.0/16) com `enable_dns_hostnames = true`
- [x] 2 subnets públicas em AZs diferentes (us-east-1a: 10.0.1.0/24 e us-east-1b: 10.0.3.0/24)
- [x] 2 subnets privadas em AZs diferentes (us-east-1a: 10.0.2.0/24 e us-east-1b: 10.0.4.0/24)
- [x] Internet Gateway configurado com Route Table associada às subnets públicas
- [x] EC2 t2.micro na subnet pública (us-east-1a) — instância `i-0993050115c3f934f`
- [x] Security Groups configurados (SSH porta 22, API porta 3000)
- [x] API Node.js respondendo via HTTP na porta 3000
- [x] Conexão SSH confirmada — Node.js v18.20.8, serviço systemd ativo
- [x] `terraform destroy` executado — 17 recursos destruídos

---

## Evidência dos Outputs do Terraform

```
ami_id                = "ami-085b153e241f89f29"
api_health_url        = "http://100.27.230.53:3000/health"
api_security_group_id = "sg-0e5e0f00b5654bf0a"
api_url               = "http://100.27.230.53:3000"
db_security_group_id  = "sg-06e24e4b76217d134"
ec2_availability_zone = "us-east-1a"
ec2_instance_id       = "i-0993050115c3f934f"
ec2_private_ip        = "10.0.1.227"
ec2_public_ip         = "100.27.230.53"
internet_gateway_id   = "igw-04d1fd5648bb5aa5c"
key_pair_name         = "technova-key"
private_key_path      = <sensitive>
private_subnet_cidrs  = [
  "10.0.2.0/24",
  "10.0.4.0/24",
]
private_subnet_ids    = [
  "subnet-07bc4e672db1e1535",
  "subnet-06a89407fd331920a",
]
public_subnet_cidrs   = [
  "10.0.1.0/24",
  "10.0.3.0/24",
]
public_subnet_ids     = [
  "subnet-068c666127cf07e9c",
  "subnet-00ca276dc36dbd123",
]
ssh_command           = "ssh -i ./technova-key.pem ec2-user@100.27.230.53"
vpc_cidr              = "10.0.0.0/16"
vpc_id                = "vpc-01dd72ca786e0d162"
```

---

## Evidência da API Funcionando (curl)

```json
{"message":"TechNova API — Aula 04 VPC + EC2 Multi-AZ","status":"running","aluno":"Emilly Santos de Oliveira","ra":"4023575","version":"1.0.0","timestamp":"2026-09-11T01:03:59.567Z","hostname":"ip-10-0-1-227.ec2.internal","platform":"linux","nodeVersion":"v18.20.8"}

{"status":"healthy","uptime":168.232453283,"memory":{"rss":55005184,"heapTotal":8896512,"heapUsed":7456376,"external":1086059,"arrayBuffers":41162},"timestamp":"2026-09-11T01:03:59.830Z"}

{"project":"TechNova","aula":"04","tema":"VPC + EC2 Multi-AZ","ambiente":"development","region":"us-east-1","multiAZ":true,"subnets":["10.0.1.0/24","10.0.3.0/24","10.0.2.0/24","10.0.4.0/24"]}
```

---

## Evidência SSH na Instância

```
v18.20.8
10.8.2
● technova-api.service - TechNova API — Node.js
     Loaded: loaded (/etc/systemd/system/technova-api.service; enabled; preset: disabled)
     Active: active (running) since Fri 2026-09-11 01:01:11 UTC; 9min ago
   Main PID: 12713 (node)
      Tasks: 7 (limit: 1113)
     Memory: 15.6M
        CPU: 181ms
     CGroup: /system.slice/technova-api.service
             └─12713 /usr/bin/node /opt/technova-api/server.js

Sep 11 01:01:11 ip-10-0-1-227.ec2.internal systemd[1]: Started technova-api.service - TechNova API — Node.js.
Sep 11 01:01:11 ip-10-0-1-227.ec2.internal node[12713]: TechNova API iniciada na porta 3000
Sep 11 01:01:11 ip-10-0-1-227.ec2.internal node[12713]: Rotas: / | /health | /info
Bootstrap concluído com sucesso!
```

---

## Evidência da Instância EC2 via AWS CLI

```
-------------------------------------------------------------------------------
|                              DescribeInstances                              |
+------------+-----------------------+----------------+----------+------------+
|     AZ     |          ID           |      IP        |  State   |   Type     |
+------------+-----------------------+----------------+----------+------------+
|  us-east-1a|  i-0993050115c3f934f  |  100.27.230.53 |  running |  t2.micro  |
+------------+-----------------------+----------------+----------+------------+
```

---

## Evidência do Terraform Destroy

```
terraform_data.infra_summary: Destruction complete after 0s
terraform_data.region_check: Destruction complete after 0s
local_sensitive_file.private_key: Destruction complete after 0s
aws_route_table_association.public[0]: Destruction complete after 1s
aws_route_table_association.public[1]: Destruction complete after 1s
aws_subnet.private[0]: Destruction complete after 1s
aws_subnet.private[1]: Destruction complete after 1s
aws_security_group.db: Destruction complete after 1s
aws_route_table.public: Destruction complete after 1s
aws_instance.api: Destruction complete after 21s
aws_key_pair.technova: Destruction complete after 0s
tls_private_key.technova: Destruction complete after 0s
aws_subnet.public[0]: Destruction complete after 1s
aws_internet_gateway.main: Destruction complete after 1s
aws_subnet.public[1]: Destruction complete after 1s
aws_security_group.api: Destruction complete after 1s
aws_vpc.main: Destruction complete after 1s

Destroy complete! Resources: 17 destroyed.
```
