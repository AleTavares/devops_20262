# Trabalho em Aula — Aula 09: Tagging e AI Review

**Aluno:** Gabriel Reis Cunha
**RA:** 6325149
**Data:** 23/10/2026

## Parte 1 — Estratégia de Tagging

| Evento | Tag sugerida | Justificativa |
|--------|-------------|---------------|
| Push para `main` | `sha-a1b2c3d` + `latest` | Com 5–10 commits por dia, o SHA identifica exatamente qual commit gerou a imagem (rastreabilidade e rollback preciso); `latest` é só conveniência para quem quer "o mais novo" |
| Push para `develop` | `sha-a1b2c3d` + `develop` | O QA testa versões específicas: o SHA fixa a versão, e `develop` é uma tag móvel para o ambiente de homologação. Nunca vai para produção |
| Git tag `v1.2.3` | `1.2.3`, `1.2` e `1` (+ `sha-…`) | A release quinzenal precisa de um nome comunicável. `1.2.3` é imutável; `1.2` recebe só correções e `1` aceita novas features, então cada consumidor escolhe quanto risco aceita |
| Pull Request | nenhuma (não publica); no máximo `pr-123`, efêmera, num registry de testes | PR é código não revisado: não deve gerar imagem no registry oficial. O CI só faz o build para validar |

- **Tags que NUNCA devem ir para produção (e por quê):** `latest` (muda a cada merge, não dá para saber qual código está rodando e o rollback fica impossível); `develop`/nomes de branch (tags móveis de desenvolvimento); `pr-N` e tags `test`/`dev`/`local` (código não aprovado). Tags móveis como `1` e `1.2` também são arriscadas em produção, porque o conteúdo muda sem o deploy mudar: produção deve fixar `X.Y.Z` ou o `sha-…`. Rollback rápido é só voltar para a tag anterior (por exemplo `1.0.1` → `1.0.0`), sem rebuild.

## Parte 2 — O que a IA deve revisar em um PR

| # | O que verificar | Severidade | Humano também revisa? |
|:-:|----------------|:----------:|:--------------------:|
| 1 | Secrets/credenciais hardcoded (senha, API key, token) | CRITICAL | Sim (confirmar se é real e rotacionar) |
| 2 | SQL injection (query montada por concatenação/interpolação) | CRITICAL | Sim |
| 3 | `eval()` e command injection (`exec` com input) | CRITICAL | Sim |
| 4 | Chave de acesso AWS (`AKIA…`) e chave privada no código | CRITICAL | Sim (revogar a chave) |
| 5 | Dependência com vulnerabilidade conhecida (CVE) | WARNING | Sim (avaliar se é explorável no nosso uso) |
| 6 | Permissões excessivas em workflows/IAM (`write-all`, `*`) | WARNING | Sim |
| 7 | `console.log` de debug em código de produção | WARNING | Não (a IA resolve sozinha) |
| 8 | `catch` vazio (erro silenciado) | WARNING | Sim (às vezes ignorar o erro é intencional) |
| 9 | Problemas de performance (loops pesados, consulta N+1) | WARNING | Sim |
| 10 | TODO/FIXME esquecidos, nomes fora do padrão e documentação ausente | INFO | Não |

### Discussão

- **Itens em que a IA é melhor que humanos:** tarefas repetitivas e de busca em texto, como secrets, `eval`, `console.log` e `catch` vazio em todo o diff, checklists longos, PRs grandes em que o revisor cansa, e consistência: ela aplica a mesma regra todo dia, em segundos. Na prática vi isso no meu TF: o AI review achou em 12 s os 4 CRITICAL de um arquivo de teste.
- **Itens que só humanos revisam bem:** regras de negócio (o cálculo do pedido está certo?), decisões de arquitetura e design de API, UX, e a justificativa de uma exceção (por exemplo, um `0.0.0.0` intencional em container). A IA vê o código, não a intenção.
- **Cenário em que eu NÃO confiaria na IA:** para aprovar sozinha mudanças em autenticação, pagamentos ou infraestrutura; em código com contexto complexo, que ela só vê pelo diff (não sabe se a variável vem do usuário nem se há sanitização acima); e quando o time passa a tratar "o review passou" como "o código é seguro". Também há falsos positivos: no meu pipeline, o `console.log` dentro de um YAML e a senha de exemplo num teste disparavam alerta, e foi preciso ajustar as regras. E falsos negativos: um secret montado por concatenação passa sem ser visto.
