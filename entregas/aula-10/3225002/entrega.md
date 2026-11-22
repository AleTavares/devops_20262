# Entrega — Aula 10: Terraform Automatizado e CD Pipelines

**Aluno:** José Henrique Teixeira Luiz
**RA:** 3225002
**Data:** 23/10/2026

## Repositório

- URL: https://github.com/zzin742/unifaat-devops-portfolio
- Pasta da aula: [`aula-10/`](https://github.com/zzin742/unifaat-devops-portfolio/tree/main/aula-10)
- Análise: [`aula-10/gitops-cd-analise.md`](https://github.com/zzin742/unifaat-devops-portfolio/blob/main/aula-10/gitops-cd-analise.md)
- Runbook: [`aula-10/docs/runbook-rollback.md`](https://github.com/zzin742/unifaat-devops-portfolio/blob/main/aula-10/docs/runbook-rollback.md)

## Evidências

- [x] Workflow `terraform-plan.yml` postando o plan como comentário no PR
- [x] Workflow `terraform-apply.yml` aplicando no merge para main
- [x] Autenticação na AWS via credenciais temporárias de sessão do Lab (secrets)
- [x] Pipeline CD completo: lint → test → build → push (ECR) → deploy
- [x] Deploy Recreate via SSH na EC2 (login ECR antes do pull)
- [x] Health check pós-deploy funcionando
- [x] `gitops-cd-analise.md` preenchido
- [ ] Screenshots — **substituídos pelos links das execuções**, abaixo

## Evidência do pipeline rodando

Tudo abaixo foi executado de verdade no Learner Lab, não é configuração no papel.

### Terraform Plan no PR

https://github.com/zzin742/unifaat-devops-portfolio/actions/runs/39879185130

PR de demonstração: https://github.com/zzin742/unifaat-devops-portfolio/pull/3

Comentário publicado automaticamente pelo workflow:

| Etapa | Status |
|---|---|
| `fmt -check` | ✅ success |
| `validate` | ✅ success |
| `plan` | ✅ success |

```
Plan: 0 to add, 1 to change, 0 to destroy.
```

**Um comentário só**, atualizado a cada push em vez de empilhar novos (bônus).

### Terraform Apply no merge

https://github.com/zzin742/unifaat-devops-portfolio/actions/runs/39879266743

O apply rodou sozinho ao mergear e fez trabalho real na AWS — a tag nova
apareceu na instância:

```
$ aws ec2 describe-instances --instance-ids i-00752ac09ef1ba9de ...
|    Key    |         Value         |
|  Ambiente |  homologacao          |
|  Name     |  technova-aula10-api  |
```

### Pipeline CD completo

https://github.com/zzin742/unifaat-devops-portfolio/actions/runs/39879266725

```
✓ Lint (ESLint)
✓ Testes (Jest)
✓ Build e push no ECR
✓ Deploy na EC2 (Recreate) + health check
```

### Health check

Resposta da aplicação, de fora da instância:

```
$ curl http://3.226.97.118:3000/health
{"status":"ok","timestamp":"2026-10-23T00:39:25.104Z","version":"1.0.0"}
```

### Notificação no commit (bônus)

```
## ✅ Deploy — Aula 10
| Imagem | 867357934920.dkr.ecr.us-east-1.amazonaws.com/technova-aula10-api:sha-b9ff8aa |
| Host | 3.226.97.118 |
| Estratégia | Recreate |
| Health check | passou |
```

## Bônus implementados

| Bônus | Como |
|---|---|
| Plan detecta destroy e exige aprovação | conta `resource_changes` com ação `delete`; se > 0, avisa no comentário e **derruba o check** |
| Comentário atualizado, não duplicado | marca `<!-- terraform-plan-bot -->` e edita o existente |
| `terraform fmt -check` no plan | passo próprio, reportado na tabela |
| `GITHUB_SHA` no deploy | vai como env do container, para rastreabilidade |
| Notificação de deploy | comentário automático no commit |

## Três coisas que aprendi executando

### 1. Sem state remoto, o GitOps de Terraform é decorativo

A primeira versão usava backend local. O plan do PR mostrou `+ create` para
**todos** os recursos, mesmo com a infra já existindo — o runner é efêmero e
começava sem state. No merge, o apply falharia com `AlreadyExists`.

Corrigi com **S3 + DynamoDB** (bucket versionado e criptografado, tabela de
`LockID`). O efeito é mensurável:

```
antes:   Plan: 5 to add, 0 to change, 0 to destroy.
depois:  Plan: 0 to add, 1 to change, 0 to destroy.
```

O plan passou a dizer a verdade.

### 2. O downtime do Recreate, observado

Não precisei teorizar. Durante a demonstração, o health externo falhou por
cerca de um minuto entre o `docker rm` e o novo `docker run` — com a instância
`running`, mesmo IP e porta aberta.

A maior parte desse tempo é o `docker pull`, que acontece **depois** da
remoção. Puxar antes de derrubar reduziria a janela ao tempo de reiniciar. É o
que o runbook de rollback já faz, por ser procedimento de emergência.

### 3. A ordem no deploy não é estilo, é disponibilidade

O login no ECR vem **antes** do `docker pull` porque a imagem é privada. Na
ordem inversa, o container antigo já teria sido removido, o pull falharia com
`no basic auth credentials` e sobraria **nada no ar**.

## Sobre a autenticação

Os workflows usam as 3 credenciais temporárias de sessão como GitHub Secrets.
Funciona, mas **não é o padrão de produção**: o certo seria OIDC + role IAM,
sem chave guardada e com credencial de minutos emitida a cada execução. O
Learner Lab não permite criar OIDC provider nem roles IAM — a mesma restrição
que obrigou a usar `LabRole` e `LabInstanceProfile` prontos.

A consequência prática é chata: **as credenciais expiram a cada sessão**, então
os secrets precisam ser reconfigurados toda vez. Um pipeline que depende de
intervenção manual recorrente é automação com muleta — exatamente o problema
que o OIDC resolve. Está detalhado na seção 2 do `gitops-cd-analise.md`.

## Limpeza

`terraform destroy` executado ao final; instância, ECR, security group, bucket
de state e tabela de lock removidos.
