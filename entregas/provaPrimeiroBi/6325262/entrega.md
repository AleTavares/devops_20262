Entrega — Prova do Primeiro Bimestre (DevOps)
Aluno: Gabriel de Souza Oliveira
RA: 6325262
Dados: [DATA DA PROVA]
Ferramentas de IA utilizadas: Claude e Kiro

Repositório do Projeto
URL: https://github.com/biel334/prova-primeiro-bimestre-devops
Checklist de Evidências
Repositório público com README (nome + RA) e .gitignore
Mínimo de 6 commits com commits convencionais + feature branch
API com CRUD completo de reservas (POST, GET, GET/:id, PUT, DELETE) + /health
Rotas de CRUD gravadas no banco PostgreSQL (não em memória)
Dockerfile funcional da API de Reservas
docker-compose.yml (API + PostgreSQL) subindo com um comando
Terraform modularizado (vpc, grupo de segurança, ec2, rds)
 RDS PostgreSQL provisionado em sub-redes privadas (banco da API na nuvem)
Estado remoto configurado (S3 + DynamoDB)
Uso de LabRole/LabInstanceProfile (sem criar IAM próprio)
terraform validar e terraform plan sem erros
relatorio.md completo (4 questões)
terraform destroy executado após evidências
Evidências
Tudo em https://github.com/biel334/prova-primeiro-bimestre-devops/tree/main/evidencias

docker-build.txt: build da imagem e container rodando como usuário não-root ( appuser)
compose-ps.txt: docker compose pscom API e PostgreSQL healthy, volume nomeado, rede bridge e CRUD local
terraform-plan.txt: plan com 18 recursos a criar
terraform-apply-e-recursos.txt: outputs, state, RDS ( PubliclyAccessible = False, StorageEncrypted = True) e state remoto no S3
api-nuvem.txte api-nuvem-crud.txt: API na EC2 com o CRUD completo gravado no RDS
terraform-destroy.txt: 18 recursos destruídos
screenshots-crud/: capturas de tela do CRUD
Relatório: https://github.com/biel334/prova-primeiro-bimestre-devops/blob/main/relatorio.md1

