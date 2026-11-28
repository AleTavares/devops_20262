# Trabalho em Aula — Aula 10: GitOps e Estratégias de Deploy

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 2026-10-22

## Parte 1 — Proteções GitOps

| # | Proteção | Como implementar |
|:-:|----------|-----------------|
| 1 | Branch protection na `main` | Settings → Branches → *Require a pull request before merging* + *Require approvals (1)* + *Do not allow bypassing* — ninguém faz push direto na branch que dispara o apply |
| 2 | Plan obrigatório e revisado no PR | Workflow `terraform-plan.yml` comenta o plan no PR e é *required status check*; se `fmt`, `validate` ou `plan` falharem, o merge fica bloqueado |
| 3 | Gate de destroy | O workflow conta as ações `delete` do plan (`terraform show -json tfplan \| jq`) e falha se houver destroy/replace sem a label `allow-destroy` — exige uma segunda decisão consciente |
| 4 | CODEOWNERS para `.tf` | `.github/CODEOWNERS` com `*.tf @time-devops` + *Require review from Code Owners*: mudança de infra só entra com aprovação de quem conhece a infra |
| 5 | State remoto com lock | Backend S3 (versionado) + DynamoDB: o lock impede dois applies simultâneos e o versionamento do bucket permite recuperar um state anterior; `concurrency` no workflow enfileira applies em vez de rodar em paralelo |
| 6 | Permissões separadas (produção) | OIDC com uma role **só-leitura** para o plan dos PRs e outra com escrita só para a `main` (trust policy restrita a `ref:refs/heads/main`) |

Implementei 1, 2, 3 e 5 no TF desta aula ([portfólio, aula-10](https://github.com/lucaskenway/unifaat-devops-portfolio/tree/main/aula-10)); o 6 não é possível no Learner Lab (sem OIDC/IAM).

- **O que acontece se o apply falhar depois do merge:** o Terraform não é transacional — os recursos criados antes do erro ficam criados e **são gravados no state**, então o state não fica "corrompido", e sim refletindo um apply **parcial**. O problema é a `main` dizer uma coisa e a AWS ter só metade dela. O caminho é: ler o erro, corrigir em um **novo PR** (o plan mostra exatamente o que falta) e deixar o apply convergir. Se o lock ficar preso (runner morto no meio), liberar com `terraform force-unlock <ID>` depois de confirmar que nada está rodando.
- **Rollback de infraestrutura / o `git revert` resolve?** Às vezes. O revert devolve o **código** ao estado anterior e o próximo apply tenta fazer a AWS voltar a ele — funciona para mudanças reversíveis (uma regra de SG, um tag). **Não** resolve quando a mudança destruiu algo com dados (um RDS apagado volta **vazio**), quando o recurso foi recriado com outro ID/IP, ou quando o apply falhou no meio (o revert gera um plan novo, que precisa ser revisado como qualquer outro). Infra não tem "desfazer"; tem um novo plan na direção oposta.
- **Como prevenir destroy acidental do RDS (2 soluções):**
  1. `lifecycle { prevent_destroy = true }` no `aws_db_instance` — qualquer plan que destrua ou recrie o banco **falha**, então o PR não passa no check.
  2. `deletion_protection = true` no próprio RDS (proteção do lado da AWS, vale até para quem usa o console/CLI) + `skip_final_snapshot = false` com `final_snapshot_identifier` e backups automáticos (`backup_retention_period`) — mesmo que o destroy aconteça, há snapshot para restaurar.
  3. (extra) o gate de destroy do workflow de plan: destroy só passa com a label `allow-destroy` e revisão.

## Parte 2 — Estratégia de Deploy por Aplicação

| Aplicação | Estratégia escolhida | Justificativa |
|-----------|:--------------------:|---------------|
| Admin Dashboard | **Recreate** | 5 usuários internos, horário comercial: faz o deploy fora do expediente e alguns segundos fora do ar não afetam ninguém. É a opção mais barata (1 instância, sem load balancer) e nunca há duas versões falando com o banco ao mesmo tempo |
| API de Pedidos | **Blue-Green** (evoluindo para Canary) | API pública com 500 req/min e SLA 99,9% (~43 min de indisponibilidade por mês): não pode ter o downtime do Recreate. Blue-Green dá zero downtime e rollback instantâneo (volta o tráfego para o ambiente antigo). Com mais tráfego e métricas, Canary reduz o risco liberando a versão nova para uma fração dos usuários |
| Job de Relatórios | **Recreate** | Roda 1x por dia às 3h: basta trocar a imagem entre execuções. Não atende tráfego, então "downtime" não existe para ninguém; Blue-Green/Canary só gastariam dinheiro (e um job duplicado poderia processar os dados duas vezes) |

**Custo de cada estratégia:** Recreate — nenhuma infra extra. Rolling — precisa de pelo menos 2 instâncias atrás de um load balancer. Blue-Green — o dobro da infra durante o deploy + load balancer/DNS para trocar o tráfego. Canary — load balancer com divisão por peso e, principalmente, observabilidade (métricas de erro/latência por versão) para decidir avançar ou voltar.

**A TechNova hoje (1 servidor) pode usar Blue-Green?** Não como está. Precisaria de um **load balancer** (ALB) ou DNS para alternar o tráfego, de **capacidade para dois ambientes** (duas EC2, ou dois containers na mesma máquina atrás de um proxy reverso como Nginx — um "blue-green de pobre"), de um **health check** que decida a troca, e de **migrações de banco compatíveis** com as duas versões rodando ao mesmo tempo.

**Quando Recreate é MELHOR que Blue-Green:** quando a versão nova é incompatível com a antiga rodando junto (migração de schema destrutiva, formato de mensagem em fila que muda); quando há só uma instância e o custo da infra dobrada não se paga; para jobs batch e workers que consomem fila (duas versões consumindo ao mesmo tempo dá processamento duplicado); e em dev/staging, onde simplicidade vale mais que disponibilidade.

### Discussão
- **Downtime aceitável (para quem?):** 5 segundos não importam para o dashboard interno usado em horário comercial nem para o job das 3h; para a API de pedidos são ~40 requisições falhando, possivelmente pedidos perdidos e consumo do orçamento de erro do SLA. A pergunta certa é "quantos usuários/requisições e quanto custa cada falha".
- **Custo de zero downtime:** infraestrutura dobrada durante o deploy (Blue-Green) ou um load balancer + pelo menos duas instâncias (Rolling/Canary), mais a complexidade de manter migrações retrocompatíveis e o investimento em monitoramento. Vale a pena onde o SLA exige — não em tudo.
- **O que a TechNova deve fazer agora vs planejar para 6 meses:** **agora** — Recreate automatizado com health check, tag imutável por commit e rollback documentado (o que foi implementado no TF da Aula 10), puxar a imagem antes de parar o container para reduzir o downtime, e `prevent_destroy`/backups no banco. **Em 6 meses** — ALB + duas instâncias para Blue-Green na API de pedidos, migrações retrocompatíveis (expand/contract), métricas e alertas por versão e, com isso, Canary; manter Recreate no dashboard e no job, onde ele continua sendo a escolha certa.
