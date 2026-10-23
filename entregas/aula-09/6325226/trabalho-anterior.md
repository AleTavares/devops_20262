# Trabalho Anterior (TA) — Aula 09: Docker Registry e IA no CI/CD

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 2026-10-15

## Questões de Verificação

| Questão | Resposta |
|:-------:|:--------:|
| 1 | **c** |
| 2 | **b** |
| 3 | **b** |
| 4 | **c** |
| 5 | **b** |

### Questão 1 — Tagging com rastreabilidade total

**c) Tag com Git SHA (ex.: `sha-a1b2c3d`), porque vincula a imagem ao commit exato.**

O SHA identifica um único commit, então `git show a1b2c3d` responde "que código está nesta imagem?". `latest` (a) e o nome da branch (d) se movem a cada push e não identificam um build. A data/hora (b) diz *quando* a imagem foi buildada, mas não *qual* código ela contém.

### Questão 2 — Autenticação no ECR pelo Learner Lab

**b) Com `aws ecr get-login-password` passando o token temporário para `docker login` com o usuário `AWS`.**

```bash
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
```

O Lab não permite criar IAM (a). O `GITHUB_TOKEN` (c) só serve para o ghcr.io. O ECR é privado por padrão (d). O token vale cerca de 12h, mas as credenciais da sessão do Lab que o geram expiram antes, a cada sessão.

### Questão 3 — Achado CRITICAL no AI review

**b) Bloquear o PR (exit 1) e exigir correção antes do merge.**

É a função do quality gate: CRITICAL (secret exposto, injection, `eval`) bloqueia, WARNING e INFO só informam. Ignorar (a) ou só comentar (c) torna o gate inútil. Desligar o workflow (d) remove a proteção justamente quando ela é necessária. Se for falso positivo, um humano revisa e corrige a regra ou o código, sem desligar o gate.

### Questão 4 — Principal limitação do AI review

**c) A IA vê apenas o diff do PR, sem entender o contexto completo do sistema e as decisões de negócio.**

Ela não sabe se a regra de negócio está certa, se a mudança faz sentido na arquitetura nem se uma função antiga chamada pelo código novo é insegura. As outras opções são falsas: ela lê JS, é mais rápida que humanos e posta comentários pela API do GitHub.

### Questão 5 — Vantagem de publicar no registry

**b) Garante que a mesma imagem testada no CI é a executada em produção (build once, run anywhere).**

Rebuildar no servidor pode gerar uma imagem diferente: uma dependência "flutuante" ou uma imagem base atualizada no meio do caminho. Com o registry, a produção puxa exatamente o digest que passou nos testes, e o rollback vira só o pull de uma tag anterior. O registry não reduz a imagem (a), não substitui o Dockerfile (c) e não roda testes (d). O *scan on push* do ECR verifica vulnerabilidades, mas não executa os testes da aplicação.

## Dúvidas para a discussão

- Com credenciais do Lab que expiram a cada sessão, como manter o push automático no CI sem atualizar os secrets toda hora? (Em produção seria OIDC, que o Lab não permite.)
- O gate deve bloquear por CRITICAL vindo de um LLM, que é não determinístico, ou só por regras estáticas?
