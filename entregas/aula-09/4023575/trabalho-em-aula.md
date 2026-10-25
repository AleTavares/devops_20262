# Trabalho em Aula — Aula 09: Tagging e AI Review

**Aluno:** Emilly Santos de Oliveira
**RA:** 4023575
**Data:** 25/10/2026

## Parte 1 — Estratégia de Tagging

| Evento | Tag sugerida | Justificativa |
|--------|-------------|---------------|
| Push para `main` | `sha-<7chars>` + `latest` | Rastreabilidade por commit e conveniência para ambientes de homologação |
| Push para `develop` | `dev-<sha-7chars>` | Identifica builds de desenvolvimento sem poluir as tags de produção |
| Git tag `v1.2.3` | `1.2.3`, `1.2`, `1` | Semver permite que sistemas downstream fixem compatibilidade por nível de estabilidade |
| Pull Request | `pr-<número>-<sha-7chars>` | Permite testar a imagem do PR isoladamente sem afetar `latest` |

- **Tags que NUNCA devem ir para produção (e por quê):**
  - `latest` — é mutável, não garante qual versão está rodando de fato. Um `docker pull latest` em momentos diferentes pode retornar imagens completamente diferentes, impossibilitando rastreabilidade e rollback confiável.
  - `dev-*` — são builds intermediários, sem passar pelo pipeline completo de validação e aprovação.
  - `pr-*` — código ainda não revisado nem mergeado, pode conter bugs ou vulnerabilidades.

## Parte 2 — O que a IA deve revisar em um PR

| # | O que verificar | Severidade | Humano também revisa? |
|:-:|----------------|:----------:|:--------------------:|
| 1 | Secrets/credenciais hardcoded (`password=`, `apikey=`, `token=`) | CRITICAL | Não — IA detecta melhor |
| 2 | Uso de `eval()` — risco de RCE | CRITICAL | Não — padrão sintático óbvio |
| 3 | SQL Injection (concatenação de variáveis em queries) | CRITICAL | Sim — contexto pode mudar o risco |
| 4 | Command Injection (`exec`/`spawn` com template literal) | CRITICAL | Sim — depende da origem do input |
| 5 | `console.log` em código de produção | WARNING | Não — IA detecta consistentemente |
| 6 | Bloco `catch` vazio que silencia erros | WARNING | Sim — às vezes é intencional |
| 7 | TODO/FIXME indicando dívida técnica não resolvida | WARNING | Sim — humano avalia a gravidade |
| 8 | Prototype Pollution (`__proto__` com input externo) | WARNING | Sim — contexto importa |
| 9 | URLs `http://` sem TLS em produção | INFO | Não — IA detecta facilmente |
| 10 | Uso de `==` em vez de `===` (coerção de tipo) | INFO | Não — regra objetiva |

### Discussão

- **Itens em que a IA é melhor que humanos:**
  Detecção de padrões sintáticos conhecidos (secrets, eval, console.log) — não se cansa, não esquece, analisa 100% das linhas sem distração. Aplica as mesmas regras em todos os PRs com consistência total e revisa um diff grande em milissegundos, antes de qualquer humano olhar.

- **Itens que só humanos revisam bem:**
  Lógica de negócio (a IA não sabe se `if (user.role === 'admin')` está correto para as regras da aplicação), arquitetura e design de API, controle de acesso e autorização (um endpoint sem `authMiddleware` pode ser intencional ou um bug grave) e qualidade dos casos de teste.

- **Cenário em que eu NÃO confiaria na IA:**
  Em uma mudança de IAM policy ou permissões de banco de dados. A IA pode não entender o princípio do menor privilégio aplicado ao contexto específico da aplicação — uma policy que parece restrita sintaticamente pode dar acesso excessivo na prática. Nesses casos, exijo revisão humana especializada obrigatoriamente, independente do que a IA disser.
