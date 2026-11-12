# Trabalho em Aula — Aula 10: GitOps e Estratégias de Deploy

**Aluno:** Sirlande Martins  
**RA:** 6325269  
**Data:** 25/10/2026

## Parte 1 — Proteções GitOps

| # | Proteção | Como implementar |
|:-:|----------|-----------------|
| 1 | Branch protection na `main` | Settings → Branches → exigir PR, pelo menos 1 aprovação, bloquear push direto e force push, valendo também para administradores |
| 2 | `terraform plan` obrigatório no PR, com o resultado visível | Workflow no evento `pull_request` rodando `fmt -check`, `validate` e `plan`, postando o plan como comentário no PR e marcado como *required status check* |
| 3 | Bloquear plan que destrói recurso | Step que roda `terraform show -json tfplan` e falha se houver alguma ação `delete` (com `jq`), só liberando com um rótulo explícito no PR, como o `aprovado-destroy` que usei no laboratório |
| 4 | Aprovação manual antes do apply | GitHub *Environment* `production` com *required reviewers*; o job de apply usa `environment: production` e só roda depois que alguém aprova |
| 5 | Dono obrigatório do código de infra | Arquivo `CODEOWNERS` com `/terraform/ @time-infra` e a opção "Require review from Code Owners" ligada |
| 6 | State protegido e com lock | Backend S3 com versionamento e criptografia, lock do state (`use_lockfile` no S3 ou tabela DynamoDB) e `concurrency` no workflow para nunca rodar dois applies ao mesmo tempo |
| 7 | Credencial de curta duração | OIDC com role AWS restrita ao repositório e à branch `main`, sem access key guardada em secret |

- **O que acontece se o apply falhar depois do merge:** o Terraform aplica recurso por recurso e não desfaz o que já foi criado quando um deles falha, então o state fica parcial, refletindo só o que deu certo, e a `main` passa a descrever uma infraestrutura que não existe por inteiro. O state em si não corrompe, porque ele só registra o que foi aplicado (e com o lock nenhum outro apply entra no meio), mas a infraestrutura fica num meio-termo. O `git revert` ajuda, mas não resolve sozinho: ele volta o código, e o próximo apply tenta levar a infra até a versão anterior, o que funciona para mudança de configuração, mas não traz de volta dado perdido. Um banco apagado continua apagado depois do revert, e um recurso criado pela metade às vezes precisa de `terraform import` ou ajuste manual antes do apply passar. Por isso o rollback de infraestrutura é mais "consertar para a frente" do que voltar no tempo, e a prevenção vale muito mais que o rollback. Na prática eu olharia o log do apply, rodaria um `plan` para ver a diferença real e corrigiria num PR novo, com o S3 versionado guardando o state anterior caso precise.
- **Como prevenir destroy acidental do RDS (2 soluções):** a primeira é no próprio Terraform, com `lifecycle { prevent_destroy = true }` no `aws_db_instance`, que faz o plan falhar com erro em vez de destruir, mais `deletion_protection = true`, que faz a própria AWS recusar a exclusão mesmo se alguém tentar por fora. A segunda é no pipeline e nos dados: o check de plan que barra qualquer `delete` (proteção 3) somado à aprovação manual do environment, e como última rede `skip_final_snapshot = false` com `final_snapshot_identifier` e backups automáticos com retenção, para que mesmo no pior caso exista um snapshot para restaurar.

## Parte 2 — Estratégia de Deploy por Aplicação

| Aplicação | Estratégia escolhida | Justificativa |
|-----------|:--------------------:|---------------|
| Admin Dashboard | Recreate | São 5 funcionários e só em horário comercial. O deploy fora desse horário não derruba ninguém, é a estratégia mais simples e mais barata, e não há risco de duas versões convivendo |
| API de Pedidos | Canary (com Rolling como passo intermediário) | API pública com 500 req/min e SLA de 99.9% não pode ter downtime, e com esse volume um problema numa versão nova aparece rápido nas métricas de 5% a 10% do tráfego. Se o erro subir, volta para a versão anterior afetando só uma parte dos clientes. Enquanto não houver infraestrutura para canary, Rolling atrás do load balancer já garante o zero downtime |
| Job de Relatórios | Recreate | Roda uma vez por dia às 3h e não atende requisição de ninguém. Basta trocar a imagem antes da próxima execução; duas versões rodando ao mesmo tempo seria até perigoso, porque poderiam processar os mesmos dados duas vezes |

### Discussão
- **Downtime aceitável (para quem?):** depende de quem está do outro lado. Para o dashboard interno, 5 segundos às 19h é invisível, ninguém está usando. Para a API de pedidos, 5 segundos a 500 req/min são cerca de 40 requisições falhando, e se uma delas for um pagamento é um cliente reclamando e o SLA sendo consumido (99.9% dá uns 43 minutos por mês de margem). Para o job das 3h, o que importa não é downtime, é ele rodar no horário e terminar.
- **Custo de zero downtime:** Blue-Green é o mais caro, porque mantém um segundo ambiente inteiro pronto, ainda que só durante a troca; Canary e Rolling precisam de pelo menos duas instâncias e de um load balancer distribuindo o tráfego, e o canary ainda pede métricas e alarmes confiáveis para saber quando voltar. O Recreate é o único que não custa nada a mais. Além da conta da AWS tem o custo de complexidade: health check, migração de banco que funcione com as duas versões ao mesmo tempo e alguém que entenda o pipeline.
- **O que a TechNova deve fazer agora vs planejar para 6 meses:** hoje, com um servidor só, Blue-Green e Canary de verdade não são possíveis sem mudar a arquitetura, então o passo agora é o que já montamos no laboratório: pipeline com plan no PR e apply no merge, proteções na `main`, deploy automatizado com health check e rollback simples para a imagem anterior pelo SHA no ECR. Para os próximos 6 meses, planejaria um ALB com pelo menos duas instâncias (ou ECS), o que já habilita Rolling para a API de pedidos, depois Blue-Green trocando target group no ALB e, com monitoramento maduro (CloudWatch com alarme de erro e latência), Canary com pesos no ALB. O dashboard e o job podem continuar em Recreate, porque ali o zero downtime não se paga.
