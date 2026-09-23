# Entrega — Aula 05: RDS e Remote State

**Aluno:** Grazielli
**RA:** 6325165
**Data:** 23/09/2026

## Repositório

- URL: https://github.com/grazykkj/unifaat-devops-portfolio

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

$ aws s3 ls s3://technova-terraform-state-v2-0291be20/aula-05/

2026-09-23 14:53:27      42989 terraform.tfstate
           --------
$ aws s3api get-bucket-versioning --bucket technova-terraform-state-v2-0291be20
{                                                                                 
    "Status": "Enabled"
}
           --------
$ aws s3api get-public-access-block --bucket technova-terraform-state-v2-0291be20
{                                                                                 
    "PublicAccessBlockConfiguration": {
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }
}

## Evidência da Conexão EC2 → RDS

[ec2-user@ip-10-0-1-166 ~]$ psql -h technova-db.cydm2izqnywl.us-east-1.rds.amazonaws.com -U technova_admin -d technova -c "SELECT version();"

                                              version                                            
  
-------------------------------------------------------------------------------------------------
--
 PostgreSQL 15.17 on x86_64-pc-linux-gnu, compiled by x86_64-pc-linux-gnu-gcc (GCC) 12.4.0, 64-bi
t
(1 row)

[ec2-user@ip-10-0-1-166 ~]$ psql -h technova-db.cydm2izqnywl.us-east-1.rds.amazonaws.com -U technova_admin -d technova -c "SELECT current_database(), current_user;"

 current_database |  current_user  
------------------+----------------
 technova         | technova_admin
(1 row)

# Evidencia Adicional

Destroy complete! Resources: 13 destroyed.

$ terraform state list
data.aws_ami.amazon_linux
data.aws_availability_zones.available
aws_dynamodb_table.terraform_locks
aws_s3_bucket.terraform_state
aws_s3_bucket_public_access_block.terraform_state
aws_s3_bucket_server_side_encryption_configuration.terraform_state
aws_s3_bucket_versioning.terraform_state
random_id.bucket_suffix