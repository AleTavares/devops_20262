 ## Trabalho em Aula — Aula 09: Tagging e AI Review

**Aluno:** FERNANDA TAVARES
**RA:** 4025109
**Data:** 20/10/2026

## Parte 1 — Estratégia de Tagging

| Evento | Tag sugerida | Justificativa |
|--------|-------------|---------------|
| Push para `main` | `sha-<commit>` + `latest` | O SHA dá rastreabilidade total (sabemos qual commit gerou a imagem) e permite rollback preciso; `latest` serve só para conveniência em dev/teste, nunca para produção. |
| Push para `develop` | `develop` + `sha-<commit>` | Identifica a origem (branch de integração) sem poluir as tags de produção; o SHA mantém a rastreabilidade de cada build. |
| Git tag `v1.2.3` | `1.2.3`, `1.2`, `1` (semver) | Release oficial. As tags flutuantes `1.2` e `1` apontam sempre para o último patch/minor, facilitando o "pin" por versão em produção. |
| Pull Request | nenhuma (não publicar) | PR só deve rodar lint/test/AI review; publicar imagem de PR polui o registry e pode expor código não aprovado. |

- **Tags que NUNCA devem ir para produção (e por quê):**
  - `latest` — não é determinística: dois pulls em momentos diferentes podem trazer imagens diferentes, impossibilitando rollback confiável e reprodutibilidade.
  - Tags de branch (`main`, `develop`) sozinhas — são móveis (mudam a cada push), então não garantem qual código está rodando.
  - Em produção: usar sempre **SHA** ou **semver**, que são imutáveis e rastreáveis.

## Parte 2 — O que a IA deve revisar em um PR

| # | O que verificar | Severidade | Humano também revisa? |
|:-:|----------------|:----------:|:--------------------:|
| 1 | Secrets/credenciais hardcoded (password, token, API key) | CRITICAL | Sim |
| 2 | SQL injection (query montada por concatenação de string) | CRITICAL | Sim |
| 3 | Uso de `eval()` / `exec()` com input do usuário | CRITICAL | Sim |
| 4 | Chaves de acesso de cloud expostas (ex.: AWS `AKIA...`) | CRITICAL | Sim |
| 5 | Catch vazio / erros silenciados | WARNING | Sim |
| 6 | `console.log` / logs de debug em código de produção | WARNING | Não |
| 7 | Binding de serviço em `0.0.0.0` sem necessidade | WARNING | Sim |
| 8 | Dependências desatualizadas ou com CVE conhecida | WARNING | Sim |
| 9 | Naming conventions e padrões de estilo (lint) | INFO | Não |
| 10 | Comentários `TODO`/`FIXME` pendentes | INFO | Não |

### Discussão

- **Itens em que a IA é melhor que humanos:** padrões repetitivos e checklists extensos — secrets, injection, console.log, TODO, naming. A IA aplica os mesmos critérios 24/7, sem cansar, e varre PRs grandes em segundos sem perder atenção.

- **Itens que só humanos revisam bem:** decisões de arquitetura, regras de negócio, corretude da lógica complexa, impacto em UX e trade-offs de produto. A IA vê só o diff e não entende o contexto completo do sistema.

- **Cenário em que eu NÃO confiaria na IA:** quando o achado depende de contexto que não está no diff (ex.: uma variável que "parece" secret mas é um placeholder de teste), ou em lógica de negócio sutil. Nesses casos a IA gera falsos positivos/negativos, e a decisão final deve ser humana. O bloqueio por CRITICAL é uma trava de segurança, não a palavra final.