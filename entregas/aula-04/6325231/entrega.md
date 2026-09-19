# Entrega — Aula 04: VPC + EC2 Multi-AZ

**Aluno:** Andreyh Rodrigues de Souza  
**RA:** 6325231  
**Data:** 17/09/2026

## Repositório

- URL: https://github.com/Andreyh117/unifaat-devops-portfolio
- Projeto: https://github.com/Andreyh117/unifaat-devops-portfolio/tree/main/aula-04

## Estado da entrega

**Execução técnica concluída no AWS Academy em 17/09/2026.** VPC e EC2 provisionados, API e SSH testados e 14 recursos destruídos após a coleta das evidências. A nota/percentual da interface do Academy dependem da conferência do professor; não foram inferidos a partir do Terraform.

## Evidências

- [x] Código da VPC com 4 subnets (2 públicas + 2 privadas) em 2 AZs
- [x] Código do Internet Gateway + Route Tables
- [x] Security Groups conforme portas e origens expressas no TF
- [x] Código EC2 t2.micro com User Data (Node.js 18 e API simplificada)
- [x] Referência ao Instance Profile existente do Academy (ver ressalva abaixo)
- [x] Tags em todos os recursos que suportam tags
- [x] README com diagrama da arquitetura e instruções
- [x] `terraform-plan-output.txt` e `evidencia-plan.txt` com plano real
- [x] API rodando: curl em `/` e `/health`
- [x] SSH: versão do Node e `aws sts get-caller-identity`
- [x] `terraform destroy` executado após evidências
- [x] Execução da infraestrutura e testes no AWS Academy (nota/percentual da interface são conferidos pelo professor)

## Compatibilidade com o AWS Academy

O TF exige criar IAM Role com `AmazonS3ReadOnlyAccess`. O laboratório da mesma aula (`aula-04/laboratorio-parte2.md`) informa que o Learner Lab bloqueia criação de roles e orienta usar `LabInstanceProfile`/`LabRole` preexistentes. O código segue essa orientação para o ambiente Academy. Não foi criada a role literal do TF, e não se afirma que a LabRole tem somente aquela policy; essa divergência precisa ser considerada pelo professor.

## Validação local

`terraform validate`: configuração válida. `terraform fmt -check -recursive` e `bash -n user_data.sh` passaram. A validação local não comprova provisionamento nem funcionamento da API.

## Evidência da API Rodando

Comandos: `curl http://52.90.186.27:3000` e `curl http://52.90.186.27:3000/health`.

```json
{"name":"TechNova API","aula":"04"}
{"status":"ok"}
```

IP temporário; infraestrutura já destruída.

## Evidência de SSH, plano e limpeza

Comando SSH: `node --version && aws sts get-caller-identity`.

```text
v18.20.8
{
    "UserId": "AROAQNK56SUZUQW42XHOK:i-0175ea5a67b644c52",
    "Account": "028651197747",
    "Arn": "arn:aws:sts::028651197747:assumed-role/LabRole/i-0175ea5a67b644c52"
}
```

```text
Plan: 14 to add, 0 to change, 0 to destroy.
Apply complete! Resources: 14 added, 0 changed, 0 destroyed.
Destroy complete! Resources: 14 destroyed.
```

Arquivos completos no portfólio:

- [terraform-plan-output.txt](https://github.com/Andreyh117/unifaat-devops-portfolio/blob/main/aula-04/terraform-plan-output.txt)
- [evidencia-plan.txt](https://github.com/Andreyh117/unifaat-devops-portfolio/blob/main/aula-04/evidencia-plan.txt)
- [evidencia-apply.txt](https://github.com/Andreyh117/unifaat-devops-portfolio/blob/main/aula-04/evidencia-apply.txt)
- [evidencia-api.json](https://github.com/Andreyh117/unifaat-devops-portfolio/blob/main/aula-04/evidencia-api.json)
- [evidencia-ssh.txt](https://github.com/Andreyh117/unifaat-devops-portfolio/blob/main/aula-04/evidencia-ssh.txt)
- [evidencia-destroy.txt](https://github.com/Andreyh117/unifaat-devops-portfolio/blob/main/aula-04/evidencia-destroy.txt)
