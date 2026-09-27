# Entrega — Aula 05: RDS e Remote State

**Aluno:** Felipe Damasceno
**RA:** 6325128  
**Data:** 10/09/2026

## Repositório

- URL: https://github.com/FelipeDesda/unifaat-devops-portfolio

## Evidências

- [x] VPC com subnets públicas e privadas em 2 AZs
- [x] RDS PostgreSQL (db.t3.micro) nas subnets privadas
- [x] EC2 t2.micro na subnet pública, conectando ao RDS
- [x] Security Groups corretos (porta 5432 apenas da VPC)
- [x] Remote State configurado (S3 + DynamoDB)
- [x] State armazenado no S3 (evidência abaixo)
- [x] Conexão EC2 → RDS via psql (evidência abaixo)
- [x] `terraform destroy` executado após evidências

## Evidência do State no S3

felip@SHASHUMGA:~/ADS/DEVOPS/unifaat-devops-portfolio/aula-05$ aws s3 ls s3://technova-tfstate-unifaat/aula-05/
2026-09-11 15:55:55      33389 terraform.tfstate


## Evidência da Conexão EC2 → RDS

[ec2-user@ip-10-0-1-218 ~]$ psql -h technova-postgres.caagdgoffedb.us-east-1.rds.amazonaws.com \
>      -U technova_admin -d technova_db -W
Password: 
psql (14.24, server 15.17)
WARNING: psql major version 14, server major version 15.
         Some psql features might not work.
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
Type "help" for help.

technova_db=> 

                      ^
[ec2-user@ip-10-0-1-218 ~]$ psql -h technova-postgres.caagdgoffedb.us-east-1.rds.amazonaws.com -U technova_admin -d technova_db -c "SELECT * FROM alunos;"
Password for user technova_admin: 
 id |   nome   | curso  
----+----------+--------
  1 | Felipe   | DevOps
  2 | TechNova | Cloud
(2 rows)

felip@SHASHUMGA:~/ADS/DEVOPS/unifaat-devops-portfolio/aula-05$ terraform plan
aws_vpc.main: Refreshing state... [id=vpc-0ebe5be522774dedf]
aws_internet_gateway.main: Refreshing state... [id=igw-082a8dde1f8d3333f]
aws_route_table.private: Refreshing state... [id=rtb-0449873a76db40990]
aws_subnet.public: Refreshing state... [id=subnet-059c522aff1c2dea2]
aws_subnet.private_1: Refreshing state... [id=subnet-0b002bd0f3f5e1ccb]
aws_subnet.private_2: Refreshing state... [id=subnet-07746117b6afbb55d]
aws_security_group.ec2: Refreshing state... [id=sg-0ff98e4309b413745]
aws_route_table.public: Refreshing state... [id=rtb-0e7806bf81b504e81]
aws_route_table_association.private_1: Refreshing state... [id=rtbassoc-0aeac8857ca6e833e]
aws_security_group.rds: Refreshing state... [id=sg-02faa463b7b066bb6]
aws_route_table_association.public: Refreshing state... [id=rtbassoc-0bf94fff145ebe58c]
aws_route_table_association.private_2: Refreshing state... [id=rtbassoc-03f95eae5a00ad7a5]
aws_db_subnet_group.main: Refreshing state... [id=technova-db-subnet-group]
aws_db_instance.postgres: Refreshing state... [id=db-W2OYRAGMSV4RNZQG2OKRG33U6Y]
aws_instance.app_server: Refreshing state... [id=i-0e10c026117e65218]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
