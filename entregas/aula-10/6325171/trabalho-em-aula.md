# Trabalho em Aula — Aula 10: GitOps e Estrategias de Deploy

**Aluno:** Nicolas de Jesus Silva  
**RA:** 6325171  
**Data:** 19/11/2026

## Parte 1 — Protecoes GitOps

| # | Protecao | Como implementar |
|:-:|----------|-----------------|
| 1 | Protecao de branch | Exigir pull request, revisao e checks obrigatorios antes do merge em `main`. |
| 2 | Plano Terraform revisado | Rodar `terraform fmt`, `validate` e `plan` no PR; revisar especialmente destruicoes e substituicoes de recursos. |
| 3 | Aplicacao controlada | Aplicar primeiro em staging; exigir aprovacao de ambiente para producao e restringir quem pode executar o workflow. |
| 4 | Permissoes minimas | Usar role temporaria e permissao minima para CI; separar credenciais de leitura de plano das de apply. |
| 5 | Estado protegido | Backend remoto com locking, versionamento e acesso restrito; nunca commitar state ou secrets. |
| 6 | Politicas preventivas | Validar politicas com regras como impedir exposicao publica indevida e impedir destruicao de recursos criticos. |

- **O que acontece se o apply falhar depois do merge:** o `apply` pode ter criado ou alterado alguns recursos antes de falhar. O Terraform normalmente persiste o estado das operacoes concluidas, mas a infraestrutura pode ficar parcialmente atualizada. Deve-se examinar logs, estado e novo `plan` antes de tentar novamente.
- **Como fazer rollback de infraestrutura:** corrigir o codigo para o estado desejado e executar um novo `plan`/`apply` revisado. Para dados ou recursos destruidos, restaurar backup/snapshot ou seguir o procedimento de recuperacao do servico.
- **O `git revert` resolve?** Nao sozinho. Ele altera o codigo versionado, mas nao desfaz automaticamente os efeitos do apply nem recupera dados. A reversao precisa de um novo plan e apply, e pode exigir restauracao separada.
- **Como prevenir destroy acidental do RDS:** habilitar deletion protection no RDS e `prevent_destroy` no Terraform; exigir aprovacao humana para mudancas que destruam/substituam; manter backups automaticos e snapshots testados.

## Parte 2 — Estrategia de Deploy por Aplicacao

| Aplicacao | Estrategia escolhida | Justificativa |
|-----------|:--------------------:|---------------|
| Admin Dashboard | Recreate | Uso interno por poucos funcionarios e horario conhecido. O custo de manter dois ambientes pode nao compensar; pode-se fazer deploy fora do horario de uso e aceitar uma interrupcao curta. |
| API de Pedidos | Canary | O trafego publico e o SLA 99.9% pedem limitar o impacto de uma regressao. A nova versao recebe uma pequena parcela do trafego, e thresholds permitem rollback para a versao estavel. |
| Job de Relatorios | Recreate | O job roda uma vez ao dia em horario programado. O deploy pode ocorrer entre execucoes; deve-se evitar duas versoes processando o mesmo lote e garantir idempotencia. Rolling ou Blue-Green so se tornam necessarios se houver requisito de execucao continua. |

### Discussao

- **Downtime aceitavel:** depende do impacto. Alguns segundos podem ser aceitaveis para um painel interno fora do expediente; para a API de pedidos, cada interrupcao afeta clientes e o SLA, portanto e necessario evitar downtime perceptivel.
- **Custo de zero downtime:** Blue-Green tende a exigir capacidade duplicada durante o deploy e um load balancer; Canary exige duas versoes simultaneas, roteamento ponderado e monitoramento. Ambos aumentam custo e complexidade em troca de reduzir risco.
- **O que a TechNova deve fazer agora vs planejar para 6 meses:** agora, proteger `main`, exigir testes e planos revisados, usar deploy controlado e health checks com rollback documentado. Em seis meses, evoluir para canary automatizado, metricas de negocio, IaC com ambientes consistentes e processos de recuperacao de dados ensaiados.
