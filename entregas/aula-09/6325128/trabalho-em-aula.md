# Trabalho em Aula — Aula 09: Tagging e AI Review

**Aluno:** Felipe Damasceno
**RA:** 6325128
**Data:** 15/10/2026

---

## Parte 1 — Estratégia de Tagging

### Estratégia adotada pela TechNova

A TechNova adota uma estratégia híbrida que combina **Semantic Versioning (SemVer)** para releases oficiais com **tags de rastreabilidade por commit** para fluxos de CI/CD contínuos. Isso atende aos quatro requisitos do contexto: alto volume de commits diários, ciclo de release quinzenal, necessidade de rollback rápido em produção e testes de QA em versões específicas.

### Tabela de tagging por evento

| Evento | Tag sugerida | Justificativa |
|--------|-------------|---------------|
| Push para `main` | `main-<sha7>` (ex.: `main-a3f8c12`) | Identifica exatamente qual commit está em execução. O SHA curto (7 chars) garante rastreabilidade sem ambiguidade, mesmo com 5-10 pushes/dia. Permite rollback preciso: basta fazer `docker pull` da tag anterior. |
| Push para `develop` | `develop-<sha7>` (ex.: `develop-b9e1d04`) | Mesma lógica de rastreabilidade, mas em branch de integração. O time de QA consegue solicitar e testar uma versão específica pelo SHA sem depender de nomes vagos. |
| Git tag `v1.2.3` | `v1.2.3` + alias `latest` | SemVer é o contrato público do artefato. A tag imutável `v1.2.3` é o que vai para produção. O alias `latest` aponta sempre para o último release estável, facilitando ambientes de staging automatizados. |
| Pull Request | `pr-<número>-<sha7>` (ex.: `pr-42-c7d0e55`) | Isola o build do PR sem poluir as tags de `main` ou `develop`. Permite ao QA testar o PR em ambiente efêmero antes do merge, e a tag some com o fechamento do PR. |

### Tags que NUNCA devem ir para produção

| Tag | Motivo |
|-----|--------|
| `latest` como único identificador | Não é imutável — pode apontar para imagens diferentes ao longo do tempo, tornando rollbacks imprevisíveis. Pode ser usada como *alias*, nunca como referência exclusiva em manifests de produção. |
| `develop-*` | Branch de integração contínua, potencialmente instável. Nunca passou pelo processo formal de release e validação de QA completo. |
| `pr-*` | Código ainda em revisão, sem aprovação de merge. Pode conter bugs, breaking changes ou experimentos descartáveis. |
| Imagens sem tag (digest apenas) | Dificultam auditoria, monitoramento e rollback operacional. Todo artefato de produção precisa de tag legível por humanos. |

---

## Parte 2 — O que a IA deve revisar em um PR

| # | O que verificar | Severidade | Humano também revisa? |
|:-:|----------------|:----------:|:--------------------:|
| 1 | **Secrets hardcoded** — senhas, tokens de API, chaves privadas expostas no código ou em arquivos de configuração commitados | CRITICAL | Sim — humano confirma o contexto (ex.: é um valor fake de teste ou credencial real?) |
| 2 | **SQL/Command Injection** — concatenação direta de input do usuário em queries SQL, comandos de shell ou expressões de template | CRITICAL | Sim — humano valida se a mitigação aplicada é suficiente para o modelo de ameaça |
| 3 | **Dependências com vulnerabilidades conhecidas** — pacotes listados no CVE ou com versões deprecadas que expõem superfície de ataque | HIGH | Sim — humano decide se atualizar a versão quebra compatibilidade |
| 4 | **Queries N+1** — loops que disparam chamadas ao banco ou a serviços externos a cada iteração em vez de usar batch/eager loading | HIGH | Sim — humano avalia se a refatoração é viável no contexto do prazo |
| 5 | **Complexidade ciclomática elevada** — funções com muitos caminhos de execução (ex.: McCabe > 10), indicando necessidade de refatoração | MEDIUM | Sim — humano julga se a complexidade é inerente ao domínio ou evitável |
| 6 | **Violações de naming conventions** — variáveis, funções e arquivos fora do padrão definido no style guide do projeto (camelCase, snake_case, etc.) | MEDIUM | Raramente — é um checklist mecânico que a IA executa melhor |
| 7 | **Código duplicado (DRY)** — blocos idênticos ou quase idênticos em mais de um lugar, candidatos a extração de função/módulo | MEDIUM | Sim — humano decide se a duplicação é acidental ou intencional (ex.: isolamento de contexto) |
| 8 | **Ausência de tratamento de erros** — chamadas a APIs externas, I/O ou operações assíncronas sem `try/catch`, verificação de `null` ou tratamento de rejeição de Promise | MEDIUM | Sim — humano valida se o comportamento de falha é aceitável para o produto |
| 9 | **Cobertura de testes insuficiente** — funções públicas novas ou alteradas sem testes correspondentes, detectável por diff de coverage | LOW | Sim — humano julga se a lógica é trivial demais para exigir teste |
| 10 | **Documentação ausente ou desatualizada** — funções públicas sem JSDoc/docstring, README sem atualização após mudança de interface, ou comentários que contradizem o código atual | LOW | Sim — humano verifica se o contexto de negócio está corretamente descrito |

### Discussão

**Itens em que a IA é melhor que humanos:**
A IA supera humanos em verificações que são, por natureza, mecânicas e exaustivas: detecção de secrets hardcoded (varredura de padrões regex em todo o diff), naming conventions (aplicação consistente de regras sem fadiga), código duplicado (comparação sintática e semântica em grande volume de código) e ausência de cobertura de testes (cruzamento automático entre diff e relatório de coverage). Humanos se cansam e falham nessas tarefas em PRs grandes; a IA não.

**Itens que só humanos revisam bem:**
Decisões de arquitetura (ex.: "devemos criar um novo serviço ou estender o existente?"), lógica de negócio (ex.: "essa regra de desconto está correta para o domínio do produto?"), avaliação de UX em fluxos complexos e julgamento sobre trade-offs de prazo vs. qualidade. Esses itens exigem contexto organizacional, histórico do produto e raciocínio sobre intenção — coisas que a IA não tem acesso completo.

**Cenário em que eu NÃO confiaria na IA:**
Em código que envolve lógica de negócio com alta carga de contexto implícito e histórico de decisões orais (ex.: regras fiscais específicas do cliente, workarounds acordados verbalmente com o time). A IA tende a sinalizar como "code smell" ou "complexidade desnecessária" código que na prática é correto e necessário por razões que não estão documentadas no repositório. Confiar cegamente nesses apontamentos geraria falsos positivos que desgastam o time e reduzem a credibilidade do processo de review automatizado.
