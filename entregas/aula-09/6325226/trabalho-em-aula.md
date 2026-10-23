# Trabalho em Aula — Aula 09: Tagging e AI Review

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 2026-10-15

## Parte 1 — Estratégia de Tagging

**Cenário da TechNova:** 5 a 10 commits por dia na `main`, release a cada 2 semanas, rollback rápido em produção e QA testando versões específicas antes do release.

**Política proposta:** toda imagem recebe uma tag **imutável** (`sha-XXXXXXX` ou semver). Tags que se movem (`latest`, `develop`) existem só por conveniência e nunca são referenciadas em deploy.

| Evento | Tag sugerida | Justificativa |
|--------|-------------|---------------|
| Push para `main` | `sha-a1b2c3d` + `latest` | Com 5–10 commits/dia, cada build precisa de um identificador único e rastreável até o commit (`git show a1b2c3d`). `latest` acompanha a main para dev local, mas não é usada em deploy. |
| Push para `develop` | `sha-a1b2c3d` + `develop` | O QA testa uma versão específica pelo `sha-` (o que foi aprovado é exatamente o que vai para release). `develop` é um ponteiro móvel para o ambiente de staging/QA sempre ter o último build. |
| Git tag `v1.2.3` | `1.2.3` + `1.2` + `1` | Release quinzenal. `1.2.3` é imutável e é o que vai para produção; `1.2` e `1` permitem a quem consome a imagem receber patches/minors automaticamente. Rollback = redeploy da tag anterior (`1.2.2`), sem rebuild. |
| Pull Request | `pr-42` (só build, **sem push**) | Código não revisado não deve virar imagem no registry. O build e o smoke test rodam no PR para pegar um Dockerfile quebrado antes do merge. Se o QA precisar de preview, `pr-42` vai para um registry/namespace de dev com expiração automática. |

**Rollback rápido:** produção roda `1.2.3` (ou o digest `@sha256:...`). Voltar é trocar para `1.2.2`, uma imagem que já está no registry e já foi testada, então leva segundos e não depende de rebuild.

**No registry da TechNova (Amazon ECR):** as releases (`1.2.3`) ficam guardadas, e uma *lifecycle policy* apaga imagens sem tag e mantém só os builds `sha-` mais recentes. Assim os 5–10 builds por dia não enchem o repositório. O *scan on push* do ECR também verifica cada imagem antes de ela ser promovida a release.

**Tags que NUNCA devem ir para produção (e por quê):**

- **`latest`**: muda a cada push na main. Dois servidores podem rodar códigos diferentes com a "mesma" tag, e não dá para responder "o que está em produção?" nem fazer rollback para um "latest anterior".
- **`develop` e nomes de branch** (`feature-x`): também são ponteiros móveis, e o código ainda não passou pelo ciclo de release.
- **`pr-*`**: código não mergeado, possivelmente não revisado.
- **`1` / `1.2` (semver parcial)**: também se movem quando sai um patch. São úteis para consumidores, mas o deploy de produção deve fixar a versão completa (`1.2.3`) ou o digest, para o deploy ser reproduzível.

## Parte 2 — O que a IA deve revisar em um PR

| # | O que verificar | Severidade | Humano também revisa? |
|:-:|----------------|:----------:|:--------------------:|
| 1 | Secrets hardcoded (senhas, tokens, AWS keys, chaves privadas) | CRITICAL | Sim |
| 2 | SQL injection (query montada por concatenação/template) | CRITICAL | Sim |
| 3 | Command injection e `eval()` / `new Function()` com entrada do usuário | CRITICAL | Sim |
| 4 | TLS desabilitado (`rejectUnauthorized: false`) e CORS liberado para `*` | CRITICAL | Sim |
| 5 | Dependência nova com CVE conhecida ou sem versão fixada | WARNING | Sim |
| 6 | Dockerfile inseguro (`FROM :latest`, `USER root`, `chmod 777`, secret em `ENV`) | WARNING | Não |
| 7 | Tratamento de erro ruim: `catch` vazio, promise sem `catch`, erro engolido | WARNING | Não |
| 8 | Performance: query dentro de loop (N+1), loop sem condição de saída, leitura síncrona em rota | WARNING | Sim |
| 9 | Código de debug esquecido: `console.log`, `debugger`, testes com `.only`/`.skip` | WARNING | Não |
| 10 | Código novo sem teste correspondente / rota nova sem documentação; TODO/FIXME sem issue | INFO | Sim |

**Critério da severidade:** CRITICAL é o que é explorável ou vaza credencial e por isso **bloqueia o merge**. WARNING é qualidade ou hardening que deve ser corrigido, mas não bloqueia, porque essas regras têm mais falso positivo. INFO é só sugestão.

**Critério do "humano também revisa":** "Não" só para itens mecânicos e objetivos, em que a IA acerta praticamente sempre. Todo CRITICAL passa por humano, inclusive para confirmar que não é falso positivo antes de alguém suprimir o alerta.

> Na minha entrega do TF, 20 regras desse tipo foram implementadas em `.github/scripts/ai-review.js` no `unifaat-devops-portfolio`, com o quality gate bloqueando CRITICAL.

### Discussão

- **Itens em que a IA é melhor que humanos:** os padrões repetitivos e de checklist: secrets, `eval`, `console.log`, `catch` vazio, `FROM :latest`. A IA aplica a mesma régua em todo PR, não cansa em PR de 800 linhas, não pula arquivo e funciona fora do horário (PR aberto sexta à noite recebe feedback na hora). Ela também é melhor em varrer o diff inteiro procurando texto, como uma AWS key esquecida num arquivo de config.
- **Itens que só humanos revisam bem:** regra de negócio (a IA não sabe que um pedido não pode ter `quantity <= 0` ou que um desconto não pode passar de 30%), decisões de arquitetura (se a mudança deveria existir, se está no lugar certo, acoplamento), autorização ("este usuário pode ver este pedido?"), impacto em dados pessoais/LGPD, migrações de banco e experiência do usuário/API. Também é papel do humano julgar se um alerta da IA é falso positivo.
- **Cenário em que eu NÃO confiaria na IA:** quando ela diz **"0 problemas"** num PR que mexe em autenticação, pagamento ou permissões. A IA só vê o diff, não o sistema inteiro: uma função nova pode chamar uma função insegura que já existia, ou montar o SQL numa linha e executar em outra, e passar limpa. Também não confiaria quando a IA (LLM) é a única barreira de segurança, porque ela é não determinística e pode responder diferente para o mesmo código. Por isso o gate conta achados estruturados em vez de interpretar texto livre, e o review humano continua obrigatório.
