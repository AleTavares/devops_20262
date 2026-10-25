# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Maximus Ponciano  
**RA:** 6325066  
**Data:** 01/10/2026  
**Ferramenta de IA utilizada:** Claude Code / Antigravity  

## Repositório do Projeto

- URL: https://github.com/MaximusPonciano/prova-primeiro-bimestre-devops

## Checklist de Evidências

- [x] Repositório público com README (nome + RA) e .gitignore
- [x] Mínimo de 6 commits com Conventional Commits + feature branch
- [x] API com **CRUD completo** de reservas (POST, GET, GET/:id, PUT, DELETE) + /health
- [x] Rotas de CRUD gravando no **banco PostgreSQL** (não em memória)
- [x] Dockerfile funcional da API de Reservas
- [x] docker-compose.yml (API + PostgreSQL) subindo com um comando
- [x] Terraform modularizado (vpc, security-group, ec2, rds)
- [x] **RDS PostgreSQL provisionado** nas subnets privadas (banco da API na nuvem)
- [x] Remote State configurado (S3 + DynamoDB)
- [x] Uso de LabRole/LabInstanceProfile (sem criar IAM próprio)
- [x] terraform validate e terraform plan sem erros
- [x] relatorio.md completo (4 questões)
- [x] terraform destroy executado após evidências

## 📸 Evidências do Projeto

Para manter este Pull Request limpo e organizado, **todas as evidências detalhadas (logs e capturas de tela) foram salvas diretamente no repositório original do projeto**.

🔗 **Acesse a pasta de evidências no repositório:**
[github.com/MaximusPonciano/prova-primeiro-bimestre-devops/tree/main/evidencias](https://github.com/MaximusPonciano/prova-primeiro-bimestre-devops/tree/main/evidencias)

### 🗂️ Mapeamento de Arquivos (Localizados no Repositório)

| Fase da Arquitetura | Arquivo de Evidência | Descrição do Conteúdo |
|---------------------|----------------------|-----------------------|
| 🐳 **Docker Build** | `evidencias/docker-build.txt` | Logs do build da imagem da API (`api-reservas`), comprovando o uso de *multi-stage build* e usuário *não-root*. |
| 🐙 **Docker Compose** | `evidencias/compose-ps.txt`<br>`evidencias/compose-logs.txt` | Logs locais validando o container `reservas_api` em execução junto ao banco `reservas_db` (status *healthy*). |
| ✅ **Terraform Validate** | `evidencias/terraform-validate.txt` | Validação sintática confirmando que a estrutura dos módulos AWS está correta. |
| 🗺️ **Terraform Plan** | `evidencias/terraform-plan.txt` | O blueprint de provisionamento apontando as criações modulares (`Plan: 19 to add, 0 to change, 0 to destroy`). |
| 🖼️ **Execução / APIs** | `evidencias/screenshots/image.png` | Capturas de tela adicionais do funcionamento do ambiente e chamadas da API CRUD. |

> 💡 **Nota ao Avaliador:** Por favor, verifique os arquivos `.txt` acima diretamente no link do repositório para inspecionar os logs completos de provisionamento do Terraform e do Docker.
