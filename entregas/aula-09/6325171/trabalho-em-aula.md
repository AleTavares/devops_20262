# Trabalho em Aula — Aula 09: Tagging e AI Review

**Aluno:** Nicolas de Jesus Silva
**RA:** 6325171
**Data de registro:** 2026-10-22

> Respostas individuais para as atividades de discussão. Ajuste a descrição da participação em grupo para refletir o que aconteceu na aula.

## Parte 1 — Estratégia de Tagging

A TechNova deve publicar uma tag imutável por commit para rastreabilidade e rollback. Releases devem usar SemVer. Tags móveis, como `latest`, `main` e `develop`, podem ajudar em ambientes de desenvolvimento, mas não devem ser a única referência de deploy. Em produção, prefiro fixar a imagem por digest ou por uma tag SemVer imutável.

| Evento | Tag sugerida | Justificativa |
|--------|-------------|---------------|
| Push para `main` | `sha-<7 caracteres>` e alias `main` | Cada build fica rastreável pelo commit; `main` aponta para o build mais recente aprovado e serve para validação, não como identidade imutável. |
| Push para `develop` | `dev-<7 caracteres>` e alias `develop` | Distingue imagens de integração e permite QA testar um build específico sem confundir com release. |
| Git tag `v1.2.3` | `1.2.3`, `1.2` e `1` | A tag de versão exata identifica o release; aliases de compatibilidade facilitam consumir atualizações dentro da mesma linha, desde que não sejam usadas como única referência para rollback. |
| Pull Request | `pr-<número>-<7 caracteres>` | Identifica o PR e commit testado. É efêmera e serve apenas para validação antes do merge. |

### Tags que nunca devem ser a única referência em produção

Não usaria `latest`, `main`, `develop`, `dev-*` ou `pr-*` como referência única de produção, pois podem mudar, representar código não aprovado ou desaparecer após limpeza. Em produção, fixaria o digest (`@sha256:...`) ou uma versão SemVer exata protegida contra sobrescrita. O digest é a referência mais inequívoca para reproduzir ou reverter um deploy.

## Parte 2 — O que a IA deve revisar em um PR

| # | O que verificar | Severidade | Humano também revisa? |
|:-:|----------------|:----------:|:--------------------:|
| 1 | Segredos e credenciais literais no diff | CRITICAL | Sim; confirmar falsos positivos e remover/rotacionar segredo exposto. |
| 2 | Access keys AWS e tokens conhecidos | CRITICAL | Sim; validar o contexto e revogar credencial se for real. |
| 3 | `eval()` e execução dinâmica de código | CRITICAL | Sim; avaliar origem e fluxo dos dados. |
| 4 | SQL montado por concatenação/interpolação | CRITICAL | Sim; revisar parâmetros, ORM e contexto da consulta. |
| 5 | Falhas de autorização ou controle de acesso | CRITICAL | Sim; exige entender papéis, recursos e regras do produto. |
| 6 | Validação ausente de entrada e possíveis XSS/command injection | CRITICAL | Sim; seguir os dados desde a entrada até o uso. |
| 7 | Dependências desatualizadas ou com CVEs conhecidos | WARNING | Sim; avaliar versão afetada, exposição e plano de atualização. |
| 8 | `console.log`, dados sensíveis em logs e `catch` vazio | WARNING | Sim; verificar se há observabilidade adequada sem vazamento. |
| 9 | Padrões de performance, como consultas N+1 e loops custosos | WARNING | Sim; medir impacto com volume e perfil de uso reais. |
| 10 | Testes ausentes, documentação desatualizada e incompatibilidade de API | INFO | Sim; conferir critérios do produto e impacto para consumidores. |

### Discussão

- **Onde a IA pode ser melhor que humanos:** procurar padrões textuais repetitivos, credenciais acidentais, chamadas perigosas, alterações sem testes e inconsistências simples em diffs extensos. Ela pode aplicar o mesmo checklist de forma rápida e uniforme.
- **O que depende mais de revisão humana:** regra de negócio, arquitetura, autorização contextual, experiência do usuário, compatibilidade com clientes e decisões que dependem de requisitos não presentes no diff.
- **Quando eu não confiaria na IA sozinha:** mudanças de autenticação/autorização, pagamentos ou dados sensíveis; diffs sem contexto; código gerado ou minificado; e qualquer decisão em que um falso negativo tenha alto impacto. Ausência de alertas não prova que o código é seguro.

## Relação com a implementação da Aula 09

O analisador atual do portfolio implementa seis regras: possíveis segredos, access keys AWS, `eval()`, SQL dinâmico, `console.log` e `catch` vazio. Os itens sobre autorização, validação de entrada, dependências, performance e cobertura de testes acima são propostas para evolução; não afirmo que já estejam implementados no analisador.
