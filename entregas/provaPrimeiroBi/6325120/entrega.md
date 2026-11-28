# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Jefferson Camargo Coelho
**RA:** 6325120
**Data:** 01/10/2026
**Ferramenta de IA utilizada:** Kiro 
## Repositório do Projeto

- URL: https://github.com/Jeff06-coder/prova-primeiro-bimestre-devops
## Checklist de Evidências

- [ ] Repositório público com README (nome + RA) e .gitignore
- [ ] Mínimo de 6 commits com Conventional Commits + feature branch
- [ ] API com **CRUD completo** de reservas (POST, GET, GET/:id, PUT, DELETE) + /health
- [ ] Rotas de CRUD gravando no **banco PostgreSQL** (não em memória)
- [ ] Dockerfile funcional da API de Reservas
- [ ] docker-compose.yml (API + PostgreSQL) subindo com um comando
- [ ] Terraform modularizado (vpc, security-group, ec2, rds)
- [ ] **RDS PostgreSQL provisionado** nas subnets privadas (banco da API na nuvem)
- [ ] Remote State configurado (S3 + DynamoDB)
- [ ] Uso de LabRole/LabInstanceProfile (sem criar IAM próprio)
- [ ] terraform validate e terraform plan sem erros
- [ ] relatorio.md completo (4 questões)
- [ ] terraform destroy executado após evidências

## Evidências

[Cole aqui os outputs/screenshots: docker compose ps, terraform plan, etc.]

#
#   docker compose up -d
#   docker compose ps

jeff-coder@JeffersonOn:/mnt/c/Users/jeffe/OneDrive/Documentos/Programação/Faculdade/Dev
Ops/prova-primeiro-bimestre-devops$ docker compose up -d
[+] up 4/4
 ✔ Network prova-primeiro-bimestre-devops_reservas_net Created                     0.1s
 ✔ Volume prova-primeiro-bimestre-devops_postgres_data Created                     0.0s
 ✔ Container reservas_db                               Healthy                     6.7s
 ✔ Container reservas_api                              Started                     7.1s
jeff-coder@JeffersonOn:/mnt/c/Users/jeffe/OneDrive/Documentos/Programação/Faculdade/Dev
Ops/prova-primeiro-bimestre-devops$ docker compose ps
NAME           IMAGE                                COMMAND                  SERVICE    CREATED          STATUS                    PORTS
reservas_api   prova-primeiro-bimestre-devops-api   "docker-entrypoint.s…"   api        17 seconds ago   Up 10 seconds             0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
reservas_db    postgres:15-alpine                   "docker-entrypoint.s…"   postgres   17 seconds ago   Up 16 seconds (healthy)   5432/tcp
jeff-coder@JeffersonOn:/mnt/c/Users/jeffe/OneDrive/Documentos/Programação/Faculdade/Dev
Ops/prova-primeiro-bimestre-devops$ 


#   docker build -t reservas-api ./app

jeff-coder@JeffersonOn:/mnt/c/Users/jeffe/OneDrive/Documentos/Programação/Faculdade/Dev
Ops/prova-primeiro-bimestre-devops$  docker build -t reservas-api ./app
#
[+] Building 0.8s (14/14) FINISHED                                      docker:default
 => [internal] load build definition from Dockerfile                              0.0s
 => => transferring dockerfile: 1.22kB                                            0.0s
 => [internal] load metadata for docker.io/library/node:20-alpine                 0.1s
 => [internal] load .dockerignore                                                 0.0s
 => => transferring context: 411B                                                 0.0s
 => [internal] load build context                                                 0.1s
 => => transferring context: 93B                                                  0.1s
 => [builder 1/4] FROM docker.io/library/node:20-alpine@sha256:3c77a043da159c2fc  0.0s
 => => resolve docker.io/library/node:20-alpine@sha256:3c77a043da159c2fce3350ad8  0.0s
 => CACHED [runner 2/6] RUN addgroup -S appgroup && adduser -S appuser -G appgro  0.0s
 => CACHED [runner 3/6] WORKDIR /app                                              0.0s
 => CACHED [builder 2/4] WORKDIR /app                                             0.0s
 => CACHED [builder 3/4] COPY src/package.json src/package-lock.json* ./          0.0s
 => CACHED [builder 4/4] RUN npm install --omit=dev                               0.0s
 => CACHED [runner 4/6] COPY --from=builder /app/node_modules ./node_modules      0.0s
 => CACHED [runner 5/6] COPY src/ ./src/                                          0.0s
 => CACHED [runner 6/6] RUN chown -R appuser:appgroup /app                        0.0s
 => exporting to image                                                            0.3s
 => => exporting layers                                                           0.0s
 => => exporting manifest sha256:6daba86c6c3a726c37293969bc248d9cc2ab820bfd3ee07  0.0s
 => => exporting config sha256:03c59cf2a3b91d98ccd5b8a598697fd9b6d61955eed3a3e50  0.0s
 => => exporting attestation manifest sha256:ae90d0b4420c5abeb26d2de8b795ae3c3eb  0.0s
 => => exporting manifest list sha256:69332138bdaee9a0adde2c1d6ca50a481f9d7827f2  0.0s
 => => naming to docker.io/library/reservas-api:latest                            0.0s
 => => unpacking to docker.io/library/reservas-api:latest                         0.0s
jeff-coder@JeffersonOn:/mnt/c/Users/jeffe/OneDrive/Documentos/Programação/Faculdade/Dev
Ops/prova-primeiro-bimestre-devops$ 


#   terraform init
#   terraform plan -var="db_password=REDACTED" -out=tfplan

jeff-coder@JeffersonOn:/mnt/c/Users/jeffe/OneDrive/Documentos/Programação/Faculdade/DevO
ps/prova-primeiro-bimestre-devops/infra/backend$ terraform init
Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.100.0...
- Installed hashicorp/aws v5.100.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
jeff-coder@JeffersonOn:/mnt/c/Users/jeffe/OneDrive/Documentos/Programação/Faculdade/DevO
ps/prova-primeiro-bimestre-devops/infra/backend$

jeff-coder@JeffersonOn:/mnt/c/Users/jeffe/OneDrive/Documentos/Programação/Faculdade/DevO
ps/prova-primeiro-bimestre-devops/infra/backend$ terraform plan -var="db_password=REDACTED" -out=tfplan
var.bucket_name
  Nome do bucket S3 para armazenar o Terraform state

  Enter a value: technova-tf-local


Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_dynamodb_table.tf_lock will be created
  + resource "aws_dynamodb_table" "tf_lock" {
      + arn              = (known after apply)
      + billing_mode     = "PAY_PER_REQUEST"
      + hash_key         = "LockID"
      + id               = (known after apply)
      + name             = "terraform-state-lock"
      + read_capacity    = (known after apply)
      + stream_arn       = (known after apply)
      + stream_label     = (known after apply)
      + stream_view_type = (known after apply)
      + tags             = {
          + "Name"    = "terraform-state-lock"
          + "Project" = "reservas-api"
        }
      + tags_all         = {
          + "Name"    = "terraform-state-lock"
          + "Project" = "reservas-api"
        }
      + write_capacity   = (known after apply)

      + attribute {
          + name = "LockID"
          + type = "S"
        }

      + point_in_time_recovery (known after apply)

      + server_side_encryption (known after apply)

      + ttl (known after apply)
    }

  # aws_s3_bucket.tf_state will be created
  + resource "aws_s3_bucket" "tf_state" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "technova-tf-local"
      + bucket_domain_name          = (known after apply)
      + bucket_prefix               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = true
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "Name"    = "technova-tf-local"
          + "Project" = "reservas-api"
        }
      + tags_all                    = {
          + "Name"    = "technova-tf-local"
          + "Project" = "reservas-api"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + cors_rule (known after apply)

      + grant (known after apply)

      + lifecycle_rule (known after apply)

      + logging (known after apply)

      + object_lock_configuration (known after apply)

      + replication_configuration (known after apply)

      + server_side_encryption_configuration (known after apply)

      + versioning (known after apply)

      + website (known after apply)
    }

  # aws_s3_bucket_ownership_controls.tf_state will be created
  + resource "aws_s3_bucket_ownership_controls" "tf_state" {
      + bucket = (known after apply)
      + id     = (known after apply)

      + rule {
          + object_ownership = "BucketOwnerEnforced"
        }
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + bucket_name         = (known after apply)
  + dynamodb_table_name = "terraform-state-lock"

───────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan"