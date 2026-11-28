# RESPOSTAS — Aula 08: GitHub Actions e CI Pipelines (TF)

**Aluno:** Carina Gonçalves dos Santos Dalpino
**RA:** 6325109
**Disciplina:** DevOps — Centro Universitário UniFAAT

Respostas conceituais sobre o pipeline CI construído para a TechNova API, demonstrando
compreensão de GitHub Actions, CI multi-stage e secrets management.

---

## 1. O que é um pipeline de CI e qual problema ele resolve na TechNova?

CI (Integração Contínua) é a prática de verificar automaticamente cada mudança de código
assim que ela chega ao repositório. Em vez de depender de um processo manual (SSH no servidor,
`git pull`, `npm install`, reiniciar e torcer), o pipeline roda sozinho a cada `push` e
`pull_request`, executando lint, testes e build. Isso dá feedback em minutos, impede que código
quebrado chegue na `main` e garante que ninguém faça deploy sem passar pelas verificações de
qualidade. Resolve exatamente a dor da TechNova: deploy demorado, sem lint, sem testes e com
risco de credenciais vazadas.

## 2. Por que o pipeline tem a ordem lint → test → build, e como ela é garantida?

A ordem é do mais barato/rápido para o mais custoso:
- **Lint** primeiro (~20s): se o estilo de código está errado, nem vale rodar o resto.
- **Test** depois: valida a lógica dos endpoints.
- **Build** por último: `docker build` é o passo mais demorado, só executa se tudo antes passou.

A ordem é garantida pela keyword `needs`: o job `test` tem `needs: lint` e o `build` tem
`needs: test`. Se um estágio falha, os seguintes nem iniciam, economizando tempo e minutos
de runner.

## 3. Como o ESLint contribui para a qualidade e como ele foi configurado?

ESLint faz análise estática — verifica o código sem executá-lo, pegando variáveis não usadas,
formatação inconsistente e possíveis bugs. No `.eslintrc.json` usei `eslint:recommended` mais
regras explícitas: `semi` (ponto e vírgula obrigatório), `quotes` (aspas simples),
`no-unused-vars`, `indent`, `no-trailing-spaces` e `eol-last`. O script `npm run lint` retorna
exit code 1 em caso de erro, e o GitHub Actions interpreta isso como falha do job, parando o
pipeline antes dos testes.

## 4. Como os testes com Jest foram estruturados e o que o coverage mostra?

A suíte em `__tests__/server.test.js` tem 9 casos cobrindo 4 endpoints: `/health`,
`GET /api/orders`, `GET /api/orders/:id` (incluindo o 404 de id inexistente) e
`POST /api/orders` (criação com 201 e validação com 400). Uso `supertest` para fazer
requisições à aplicação Express sem subir um servidor real. O `npm test` roda com `--coverage`,
gerando um relatório que mostra o percentual de linhas/branches exercitadas pelos testes —
quanto maior, mais do código está protegido contra regressões.

## 5. Como o Docker entra no CI e para que serve o smoke test?

O job `build` executa `docker build -t technova-api:${{ github.sha }} .`, usando o SHA do commit
como tag (cada build vira uma imagem rastreável). Depois vem o **smoke test**: o container sobe
(`docker run -d`), espera alguns segundos e faz `curl -f http://localhost:3000/health`. Se o
`/health` não responder 200, o job falha (e imprime os logs do container). Isso prova que a
imagem não só compila, mas realmente **sobe e atende** — ao final o container é parado e removido.

## 6. Onde ficam as credenciais e como o secret foi usado no workflow?

Credenciais nunca vão para o código nem para o YAML. Ficam em GitHub Secrets
(Settings → Secrets and variables → Actions). No workflow referencio `AWS_REGION` com
`${{ secrets.AWS_REGION }}`. O GitHub mascara o valor nos logs (aparece `***`), e secrets não
são passados para workflows disparados por PRs vindos de forks — uma proteção de design contra
roubo de credenciais em projetos públicos. Evidência em `screenshots/screenshot-secrets-configured.png`.

## 7. Por que um `.env` commitado é perigoso mesmo se for apagado depois?

Porque o git guarda o histórico. Deletar o `.env` em um commit posterior não o remove dos
commits antigos — qualquer pessoa com acesso ao repo consegue recuperar a versão com os
segredos. Bots varrem o GitHub e encontram chaves em segundos. Por isso a regra é **nunca
commitar o segredo** (`.gitignore` com `.env` desde o início) e, se vazar, **revogar/rotacionar**
a credencial, não apenas apagar o arquivo.

## 8. Quais recursos de bônus foram implementados e qual o ganho de cada um?

- **Matrix strategy (B1):** o job `test` roda em Node 18 e Node 20 em paralelo, garantindo
  compatibilidade com as duas versões.
- **Cache de dependências (B2):** `actions/setup-node` com `cache: npm` reaproveita o cache
  entre execuções, acelerando o `npm ci`.
- **Concurrency control (B4):** `concurrency` com `cancel-in-progress` cancela runs antigos do
  mesmo ref quando chega um push novo, evitando desperdício de runner.
- **Smoke test no Docker (B5):** valida que o container realmente sobe e responde no `/health`,
  indo além do simples "a imagem compilou".
