# Composição: liga a saída de um módulo à entrada do próximo
# (vpc -> security-group -> ec2/rds).

module "vpc" {
  source       = "./modules/vpc"
  nome_projeto = var.nome_projeto
  azs          = var.azs
  tags         = var.tags
}

module "security_group" {
  source       = "./modules/security-group"
  nome_projeto = var.nome_projeto
  vpc_id       = module.vpc.vpc_id
  tags         = var.tags
}

module "rds" {
  source               = "./modules/rds"
  nome_projeto         = var.nome_projeto
  subnets_privadas_ids = module.vpc.subnets_privadas_ids
  security_group_id    = module.security_group.sg_rds_id
  db_name              = var.db_name
  db_user              = var.db_user
  db_password          = var.db_password
  tags                 = var.tags
}

module "ec2" {
  source                = "./modules/ec2"
  nome_projeto          = var.nome_projeto
  subnet_id             = module.vpc.subnets_publicas_ids[0]
  security_group_id     = module.security_group.sg_ec2_id
  instance_profile_name = var.instance_profile_name
  chave_ssh_nome        = var.chave_ssh_nome
  repo_url              = var.repo_url
  repo_branch           = var.repo_branch
  db_host               = module.rds.host
  db_port               = module.rds.port
  db_name               = var.db_name
  db_user               = var.db_user
  db_password           = var.db_password
  tags                  = var.tags
}
