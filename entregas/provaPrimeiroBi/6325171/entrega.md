# Cria a pasta com seu RA
mkdir -p entregas/provaPrimeiroBi/6325171

# Cria o entrega.md
cat > entregas/provaPrimeiroBi/6325171/entrega.md << 'EOF'
# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Nicolas de Jesus Silva
**RA:** 6325171
**Data:** 30/09/2026
**Ferramenta de IA utilizada:** Kiro

## Repositório do Projeto

- URL: https://github.com/NxcolasDev/prova-primeiro-bimestre-devops

## Checklist de Evidências

- [x] Repositório público com README (nome + RA) e .gitignore
- [x] Mínimo de 6 commits com Conventional Commits + feature branch
- [x] API com CRUD completo de reservas (POST, GET, GET/:id, PUT, DELETE) + /health
- [x] Rotas de CRUD gravando no banco PostgreSQL (não em memória)
- [x] Dockerfile funcional da API de Reservas
- [x] docker-compose.yml (API + PostgreSQL) subindo com um comando
- [x] Terraform modularizado (vpc, security-group, ec2, rds)
- [x] RDS PostgreSQL provisionado nas subnets privadas
- [x] Remote State configurado (S3 + use_lockfile)
- [x] Uso de LabInstanceProfile (sem criar IAM próprio)
- [x] terraform validate e terraform plan sem erros
- [x] relatorio.md completo (4 questões)
- [x] terraform destroy executado após evidências

## Evidências

- `evidencias/docker-build.txt` — build multi-stage da imagem da API
- `evidencias/compose-ps.txt` — containers API e PostgreSQL rodando (healthy)
- `evidencias/terraform-plan.txt` — plan com 14 recursos a criar
- `evidencias/curl-crud-tests.txt` — CRUD completo testado (POST, GET, GET/:id, PUT, DELETE, /health)
EOF
