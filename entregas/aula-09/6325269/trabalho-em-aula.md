# Trabalho em Aula — Aula 09: Tagging e AI Review

**Aluno:** Sirlande Martins  
**RA:** 6325269  
**Data:** 24/10/2026

## Parte 1 — Estratégia de Tagging

| Evento | Tag sugerida | Justificativa |
|--------|-------------|---------------|
| Push para `main` | `sha-<7 primeiros do commit>` (ex.: `sha-a1b2c3d`) + `main` como tag móvel | Com 5 a 10 commits por dia, cada imagem precisa de um nome único e imutável que leve direto ao commit. A tag `main` só aponta para a última e serve para o ambiente de staging puxar sempre o mais recente |
| Push para `develop` | `develop-<sha>` + `develop` como tag móvel | O QA consegue pegar exatamente a versão que vai testar pelo SHA, e a tag móvel facilita o ambiente de desenvolvimento. O prefixo deixa claro que é imagem de branch e não de release |
| Git tag `v1.2.3` | `1.2.3`, `1.2` e o mesmo `sha-<commit>` | É a release oficial a cada duas semanas. O semver diz o que mudou, a tag `1.2.3` nunca é sobrescrita e é ela que vai para produção; o rollback é só voltar o deploy para a versão anterior (`1.2.2`), que continua no registry |
| Pull Request | `pr-<número>` (ex.: `pr-42`), sem push para o registry de produção | Serve para validar que o build funciona e, no máximo, para um ambiente de preview. É código que ainda não foi revisado, então fica num repositório separado ou com regra de expiração curta no ECR |

- **Tags que NUNCA devem ir para produção (e por quê):** `latest` é a principal, porque ela muda a cada push e não diz qual código está rodando; dois servidores que puxaram `latest` em horários diferentes podem estar com versões diferentes, e na hora do incidente ninguém sabe para qual voltar. Pelo mesmo motivo as tags móveis `main` e `develop` também ficam fora, além de `pr-*` (código não revisado) e qualquer tag de teste como `dev`, `test` ou `temp`. Em produção só entra tag semver imutável vinda de um git tag, e para garantir isso eu ligaria o *tag immutability* do ECR, que recusa o push de uma tag que já existe.

## Parte 2 — O que a IA deve revisar em um PR

| # | O que verificar | Severidade | Humano também revisa? |
|:-:|----------------|:----------:|:--------------------:|
| 1 | Secrets hardcoded (chaves AWS, senhas, tokens, string de conexão do banco) | CRITICAL | Sim |
| 2 | SQL injection: query do `pg` montada concatenando entrada do usuário em vez de usar parâmetros (`$1`, `$2`) | CRITICAL | Sim |
| 3 | Entrada da requisição usada sem validação (body, params e query no Express) | HIGH | Sim |
| 4 | Permissões amplas demais em workflow ou IAM (`permissions: write-all`, `Action: "*"`, `Resource: "*"`) | HIGH | Sim |
| 5 | Dependência nova ou atualizada com vulnerabilidade conhecida ou fora do `package-lock.json` | HIGH | Sim |
| 6 | Erro engolido ou mal tratado: `catch` vazio, promise sem `await`/tratamento, stack trace devolvido para o cliente | MEDIUM | Sim |
| 7 | Query dentro de loop (N+1) ou consulta sem `LIMIT` em tabela que cresce | MEDIUM | Sim |
| 8 | Código alterado sem teste correspondente, ou teste removido/desligado (`.skip`) | MEDIUM | Sim |
| 9 | Complexidade e duplicação: função muito longa, bloco copiado de outro arquivo | LOW | Não |
| 10 | Padrões e documentação: nome fora da convenção, `console.log` esquecido, README ou JSDoc desatualizado | LOW | Não |

### Discussão
- **Itens em que a IA é melhor que humanos:** os da parte de cima e os de baixo da tabela, por motivos diferentes. Secrets, injection, permissão ampla e `console.log` esquecido são procura de padrão em texto, e a IA olha cada linha de todo PR sem cansar, inclusive no PR de 800 linhas que um humano acaba aprovando por cansaço. Nos itens de estilo e documentação (9 e 10) ela é melhor simplesmente porque nenhum humano quer gastar atenção nisso, e tirar esse peso do revisor faz ele sobrar para o que importa.
- **Itens que só humanos revisam bem:** se a mudança faz o que o negócio precisa (a regra de desconto está certa? o pedido pode mesmo ser cancelado depois de pago?), decisões de arquitetura (vale criar um serviço novo ou isso cabe no que já existe?), e o impacto em quem usa, seja o cliente da API ou o time que vai manter o código. A IA vê o diff, mas não sabe a conversa que gerou a tarefa nem o que foi combinado com o cliente.
- **Cenário em que eu NÃO confiaria na IA:** numa mudança de lógica de negócio crítica, como o cálculo de pagamento, em que o código está sintaticamente perfeito e a IA aprova, mas a regra está errada. Ela não tem como saber que está errada, porque a regra certa não está no código. Também não confiaria nela como única barreira de segurança: ela pode dar falso negativo e deixar passar um secret com formato diferente, e pode dar tanto falso positivo que o time começa a ignorar os comentários. Por isso coloquei "Sim" na coluna humano em tudo que é CRITICAL, HIGH e MEDIUM: a IA filtra e aponta, mas quem aprova o merge continua sendo uma pessoa.
