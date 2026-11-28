# Trabalho em Aula — Aula 08: GitHub Actions e CI Pipelines

**Aluno:** Nicolas de Jesus Silva  
**RA:** 6325171  
**Data:** 19/11/2026

## Parte 1 — Design de Pipeline CI

### Estagios do pipeline (em ordem)

| Estagio | O que verifica | Obrigatorio? | Tempo estimado |
|---------|---------------|:------------:|:-------------:|
| Checkout e instalacao | Versao suportada do Node.js, `npm ci` usando lockfile e cache de dependencias | Sim | 1-2 min |
| Lint e formatacao | Erros de estilo, imports e regras do projeto | Sim | 1 min |
| Testes unitarios | Rotas, validacao, logica e regressao; publica cobertura | Sim | 1-3 min |
| Auditoria de dependencias | Vulnerabilidades conhecidas e dependencias desatualizadas | Sim, bloqueia vulnerabilidades criticas/altas | 1-2 min |
| Build da aplicacao e imagem | Compilacao e construcao reproduzivel do container | Sim | 2-4 min |
| Teste da imagem | Health check, usuario nao-root e configuracao basica do container | Sim | 1-2 min |
| Scan de imagem | Busca vulnerabilidades em camadas e imagem base | Sim, conforme threshold do time | 1-3 min |
| Publicacao | Push da imagem versionada para ECR somente apos CI verde e credenciais protegidas | Em push aprovado para main | 1-2 min |

Fluxo:

```text
[pull_request / push]
        |
        v
[npm ci] -> [lint] -> [testes] -> [auditoria] -> [build + teste da imagem]
   |            |         |            |                    |
   +-------- falha em qualquer check obrigatorio: bloquear merge
                                                           |
                                      [push para main, CI verde]
                                                           v
                                                     [publicar ECR]
```

### Respostas

- **O pipeline deve rodar em:** pull requests para validar antes do merge e em pushes para `main` para publicar a imagem aprovada. Em branches de desenvolvimento, pode executar os mesmos checks sem publicar.
- **Um PR deve ser bloqueado quando:** um teste ou lint obrigatorio falhar, houver vulnerabilidade acima do limite definido, a imagem nao construir, ou faltar aprovacao/revisao exigida. Falhas informativas podem ser avisos, mas nao devem ocultar checks essenciais.
- **Como o time fica sabendo:** status checks no PR, notificacao do GitHub e alerta no canal operacional; o log deve indicar qual etapa falhou sem imprimir segredos.

## Parte 2 — Analise de Seguranca de Credenciais

### Cenario 1 — O `.env` esquecido

- **O que aconteceu:** um arquivo com credenciais foi commitado e enviado ao repositorio.
- **Impacto:** apagar o arquivo em outro commit nao remove o conteudo do historico. Enquanto as chaves forem validas, alguem que as obteve pode chamar APIs AWS com as permissoes concedidas.
- **Como prevenir:** `.gitignore` para `.env`, secret scanning, credenciais temporarias e permissao minima. A protecao principal e nao colocar segredo no repositorio.
- **Como detectar/mitigar:** revogar ou rotacionar imediatamente as chaves, revisar CloudTrail e alertas de uso, procurar o segredo em branches/historico e avisar os responsaveis. A remocao do historico e complementar; nao substitui a revogacao.

### Cenario 2 — O workflow indiscreto

- **O que aconteceu:** o workflow tenta imprimir segredos nos logs.
- **Impacto:** a mascara do GitHub e uma protecao util, mas nao e garantia absoluta. Transformacoes, substrings, logs de ferramentas externas, artefatos e processos posteriores podem expor o valor ou permitir que seja usado.
- **Como prevenir:** nunca imprimir segredos; limitar permissao e escopo dos secrets; usar credenciais curtas; revisar workflows e proteger ambientes. Tambem nao se deve assumir que codificar ou mascarar um valor o torna seguro.
- **Como detectar/mitigar:** revisar logs e artefatos, revogar qualquer segredo possivelmente exposto e auditar o uso. Configurar secret scanning e alertas de acesso.

### Cenario 3 — O PR do fork

- **O que aconteceu:** uma contribuicao externa tenta executar um workflow com comportamento nao confiavel.
- **Impacto:** workflows acionados por `pull_request` de forks normalmente nao recebem secrets do repositorio nem token com escrita. O perigo aumenta se um workflow privilegiado executar o codigo do PR, por exemplo com configuracao inadequada de `pull_request_target`.
- **Como prevenir:** nunca executar codigo nao confiavel em um contexto que possua secrets; nao usar `pull_request_target` para checkout e execucao do head do fork; restringir `permissions` do `GITHUB_TOKEN`, proteger environments e exigir revisao antes de workflows privilegiados.
- **Como detectar/mitigar:** revisar alteracoes em workflows, auditar execucoes e permissoes do token, usar logs de auditoria e cancelar execucoes suspeitas. Se houver suspeita de exposicao, revogar credenciais e inspecionar logs e artefatos.
