# Entrega — Aula 09: Docker Registry e IA no CI/CD

**Aluno:** Nicolas de Jesus Silva
**RA:** 6325171
**Data:** 2026-10-22

## Repositório

- URL: https://github.com/NxcolasDev/unifaat-devops-portfolio
- Branch de trabalho: `feature/aula-09-ecr-ai-review`
- Projeto: `aula-09/`

## Implementação no portfólio

O projeto inclui a API TechNova em Node.js/Express, Dockerfile multi-stage, script `ecr-push.sh` para publicação no Amazon ECR, analisador de diff baseado em padrões e workflow de AI Review em Pull Requests. A análise verifica possíveis secrets/access keys, `eval()`, SQL dinâmico, `console.log` e blocos `catch` vazios. Achados CRITICAL fazem o quality gate falhar; WARNING não bloqueia.

O AI Review é baseado em regras locais, não em um modelo generativo. Ele complementa, mas não substitui, revisão humana.

## Validação local

Executados em 2026-10-22:

- `npm test` em `aula-09/technova-api`: 4 testes passaram.
- `npm run lint`: concluído sem erros.
- `npm run build`: concluído sem erros.
- `node --test aula-09/tests/ai-review.test.js`: 3 testes passaram.
- `docker --version`: Docker CLI disponível.
- `bash -n aula-09/ecr-push.sh`: sintaxe válida.
- `docker build -t technova-api:aula09-local .`: imagem multi-stage criada e inspecionada.
- Container iniciado localmente na porta `3010`: `/health` retornou `status: ok` e `/api/orders` retornou 3 pedidos; container encerrado após o teste.
- AI Review executado localmente com um valor fictício de teste: gerou achado `CRITICAL` e saiu com código `1`, confirmando o bloqueio local.

## Evidências do laboratório e status

- [x] Script `ecr-push.sh` implementado com tags SHA curto, `latest` e SemVer.
- [x] `ia-cicd-analise.md` preenchido.
- [x] Workflow de AI Review e quality gate implementados.
- [x] Build e execução local da imagem Docker validados.
- [x] Quality gate local bloqueou um achado CRITICAL fictício.
- [ ] Publicação real da imagem no Amazon ECR em `us-east-1`.
- [ ] Repositório ECR `technova-api` criado e tags confirmadas no console.
- [ ] Pull da imagem publicada e teste de rollback por tag.
- [ ] Workflow executado em um Pull Request no GitHub.
- [ ] Comentário do AI Review e bloqueio de PR com achado CRITICAL observados no GitHub.
- [ ] Screenshots das evidências AWS e GitHub adicionados ao portfólio.

Na checagem local, o AWS CLI estava disponível no WSL, mas o STS retornou `ExpiredToken`; nenhuma publicação no ECR foi feita. As tarefas pendentes dependem de uma sessão Learner Lab válida e de um Pull Request no GitHub. As credenciais AWS temporárias (access key, secret key e session token) devem ser usadas somente no ambiente local/sessão do laboratório; não devem ser incluídas neste repositório, neste arquivo ou em screenshots.

## Evidências do pipeline

Ainda pendentes. Após executar o workflow, inserir aqui o link da execução do GitHub Actions e adicionar as capturas de tela em `aula-09/screenshots/` no repositório de portfólio.
