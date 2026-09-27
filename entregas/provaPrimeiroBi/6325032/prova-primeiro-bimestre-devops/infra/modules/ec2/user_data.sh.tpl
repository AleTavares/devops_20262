#!/bin/bash
set -euxo pipefail

# Amazon Linux 2023: instala Docker e Git
dnf update -y
dnf install -y docker git
systemctl enable --now docker
usermod -aG docker ec2-user

# Clona o repositório público da API (branch configurável)
cd /opt
rm -rf app-reservas
git clone --branch "${repo_branch}" --depth 1 "${repo_url}" app-reservas
cd app-reservas/app

# Constrói a imagem localmente na instância (sem registry externo)
docker build -f src/Dockerfile -t api-reservas:latest .

# Sobe o container apontando para o RDS (nunca para um Postgres local)
docker rm -f reservas-api 2>/dev/null || true
docker run -d \
  --name reservas-api \
  --restart unless-stopped \
  -p ${app_port}:${app_port} \
  -e PORT=${app_port} \
  -e PGHOST="${db_host}" \
  -e PGPORT="${db_port}" \
  -e PGUSER="${db_user}" \
  -e PGPASSWORD="${db_password}" \
  -e PGDATABASE="${db_name}" \
  api-reservas:latest
