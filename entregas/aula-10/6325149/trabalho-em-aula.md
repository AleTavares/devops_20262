# Trabalho em Aula — Aula 10: GitOps e Estratégias de Deploy

**Aluno:** Gabriel Reis Cunha
**RA:** 6325149
**Data:** 23/10/2026

## Parte 1 — Proteções GitOps

| # | Proteção | Como implementar |
|:-:|----------|-----------------|
| 1 | Branch protection na `main` | Settings → Branches → exigir PR, aprovação (1+) e bloquear push direto/bypass, inclusive de admins |
| 2 | Plan obrigatório e verde antes do merge | Workflow `terraform-plan.yml` em `pull_request` marcado como *required status check*; `fmt -check`, `validate` e `plan` falham o PR |
| 3 | Revisão humana do plan e CODEOWNERS | Plan postado como comentário no PR; `.github/CODEOWNERS` exige o time de DevOps para `*.tf`/`*.tfvars` |
| 4 | Alerta/aprovação extra quando o plan destrói ou recria recursos | Step que procura `will be destroyed`/`must be replaced` no plan, avisa no comentário e exige *Required reviewers* (GitHub Environment) antes do apply |
| 5 | Proteção do state e concorrência | State remoto no S3 com versionamento, criptografia e lock; `concurrency` sem cancelamento no apply para nunca haver dois applies juntos |
| 6 | Credenciais mínimas e fora do código | Em produção OIDC + role IAM de menor privilégio (sem chaves); no Lab, credenciais de sessão em GitHub Secrets; nada de segredo no Git (`.gitignore`, secret scanning) |

- **O que acontece se o apply falhar depois do merge:** o `main` passa a descrever uma infraestrutura que não existe de fato (Git ≠ AWS). O Terraform grava no state o que já foi criado, então o state fica *parcial*, porém consistente com a realidade: recursos criados antes do erro existem e estão no state; os que falharam não. Não é corrupção, mas há drift entre o desejado e o real até corrigir. Como o lock é liberado ao final, o próximo `apply` retoma de onde parou depois de corrigir a causa (credencial expirada, limite de cota, erro de permissão). O `git revert` do PR resolve o **código**, e o novo apply desfaz o que foi criado, mas **não** resolve tudo: reverter um `destroy` não devolve dados (banco, volumes), e mudanças parcialmente aplicadas podem exigir `terraform import`/`state rm` ou correção manual. Rollback de infra = revert + novo PR/plan/apply, nunca editar na console.
- **Como prevenir destroy acidental do RDS (2 soluções):**
  1. `lifecycle { prevent_destroy = true }` no `aws_db_instance`: qualquer plan que o destrua falha antes do apply. Complemento: `deletion_protection = true` no RDS (a própria AWS recusa a exclusão) e `skip_final_snapshot = false` com `final_snapshot_identifier`.
  2. Controle no pipeline: detectar destroy no plan e bloquear/exigir aprovação extra (GitHub Environment com *Required reviewers*), mais backups automáticos e snapshot antes de mudanças perigosas. Opcionalmente, política IAM do pipeline que nega `rds:DeleteDBInstance`.

## Parte 2 — Estratégia de Deploy por Aplicação

| Aplicação | Estratégia escolhida | Justificativa |
|-----------|:--------------------:|---------------|
| Admin Dashboard | Recreate | 5 usuários internos em horário comercial: dá para fazer o deploy fora do expediente ou aceitar segundos de indisponibilidade. É a opção mais simples e barata, sem infraestrutura extra. |
| API de Pedidos | Blue-Green (com Canary como evolução) | API pública, 500 req/min e SLA de 99,9% (~43 min de indisponibilidade por mês): não aceita downtime a cada deploy. Blue-Green troca o tráfego instantaneamente e permite rollback imediato voltando para o ambiente antigo; Canary reduz ainda mais o risco quando houver observabilidade. |
| Job de Relatórios | Recreate | Roda 1x por dia às 3h: basta trocar a versão entre as execuções; não há tráfego a proteger. Rolling/Blue-Green só adicionariam custo e complexidade. |

### Discussão
- **Downtime aceitável (para quem?):** depende de quem usa e do SLA. 5 segundos são irrelevantes para 5 funcionários do dashboard ou para um job das 3h, mas numa API pública com 500 req/min significam ~40 requisições falhando por deploy e pesam no orçamento de erro do SLA de 99,9%. Também depende da frequência: vários deploys por dia somam.
- **Custo de zero downtime:** Blue-Green exige ambiente duplicado (≈2× o custo de computação durante a troca) ou, no mínimo, load balancer/ALB + dois alvos; Canary exige roteamento por percentual, métricas e automação de análise. Além do custo de infraestrutura há custo de complexidade (migrações de banco compatíveis com as duas versões, operação e monitoramento).
- **Perguntas adicionais:** (1) custo: Recreate ≈ zero extra; Rolling precisa de ≥2 instâncias; Blue-Green ≈ dobro; Canary = infra + roteamento/observabilidade. (2) A TechNova hoje (startup, 1 servidor) **não** consegue Blue-Green de verdade: precisaria de uma segunda instância (ou segundo container na mesma máquina) e de um load balancer/proxy (ALB ou Nginx) na frente. (3) Recreate é melhor quando não há tráfego contínuo ou o downtime é aceitável (jobs, ferramentas internas, ambientes de teste), quando o custo importa mais que a disponibilidade e quando a aplicação não consegue conviver com duas versões ao mesmo tempo (ex.: mudança de schema incompatível).
- **O que a TechNova deve fazer agora vs planejar para 6 meses:** *Agora:* manter Recreate com pipeline CD, health check, imagens com tag SHA e rollback documentado (foi o que implementei no TF), GitOps no Terraform e proteções de branch/plan. *Em 6 meses:* adicionar um ALB e uma segunda instância para Blue-Green na API de Pedidos (aula 11), métricas e alarmes para habilitar Canary (aula 12), OIDC + role IAM no lugar de credenciais estáticas e RDS com `prevent_destroy`/`deletion_protection` e backups.
