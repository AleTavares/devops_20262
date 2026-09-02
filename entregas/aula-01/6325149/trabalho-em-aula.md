# Trabalho em Aula — Discussão Guiada

## Briefing do CTO da TechNova: A Crise Dupla

> **Contexto:** A equipe de Platform Engineering (vocês) foi convocada para a primeira reunião com o CTO. Ele precisa que vocês diagnostiquem os dois problemas críticos e proponham soluções concretas.

---

## Parte 1 — O Caos do Código (Sem Controle de Versão)

### Cenário

Leia o trecho abaixo do relatório interno da TechNova:

> Na segunda-feira, o Marcos precisava implementar uma correção urgente no módulo de pagamentos. Ele abriu a pasta compartilhada no servidor e encontrou os seguintes arquivos:
>
> ```
> /servidor/codigo/
> ├── api_v2.zip
> ├── api_v2_final.zip
> ├── api_v2_final_corrigido.zip
> ├── api_v2_final_corrigido_REAL.zip
> ├── api_backup_rafael_sexta.zip
> ├── api_juliana_nova_versao.zip
> └── USAR_ESSE_AQUI.zip
> ```
>
> Marcos escolheu `USAR_ESSE_AQUI.zip`, fez a correção e sobrescreveu o arquivo. No dia seguinte, a Juliana descobriu que as alterações dela dos últimos 3 dias haviam sumido — o arquivo que Marcos usou era de uma semana atrás.

### Discussão em Grupo

Responda as seguintes questões em grupo (3-4 pessoas):

**1. Diagnóstico:** Liste pelo menos 4 problemas que podem ocorrer no cenário acima sem controle de versão.

**Resposta:**

1. **Perda de trabalho por sobrescrita** — Marcos sobrescreveu o arquivo sem saber que a Juliana tinha alterações mais recentes; não existe histórico para recuperar o que foi perdido.
2. **Ausência de fonte única de verdade** — múltiplos arquivos (`api_v2.zip`, `api_v2_final.zip`, `api_v2_final_corrigido_REAL.zip`...) representam versões concorrentes do mesmo código, sem nenhum deles ser claramente "o atual".
3. **Impossibilidade de rastrear mudanças** — não há como saber quem alterou o quê, quando, ou por quê (sem commits, sem autoria, sem timestamps confiáveis).
4. **Nenhum mecanismo de merge/colaboração paralela** — Marcos, Rafael e Juliana não conseguem trabalhar simultaneamente no mesmo módulo sem risco de um sobrescrever o outro.
5. **Convenção de nomes como controle de versão é falha e não escala** — depende de disciplina manual, o que quebra facilmente à medida que a equipe cresce.

**2. Consequências:** Qual é o impacto financeiro e operacional de perder 3 dias de trabalho de uma desenvolvedora sênior?

**Resposta:**

**Impacto financeiro:**
- Retrabalho: Juliana precisa refazer manualmente 3 dias de trabalho, custo direto em horas de uma desenvolvedora sênior.
- Atraso na entrega: a correção urgente do módulo de pagamentos também é afetada, já que ninguém tem certeza de qual versão é confiável.
- Risco de retrabalho em cascata: se o código perdido já tiver sido usado como base por outra pessoa, o erro se propaga.

**Impacto operacional:**
- Perda de confiança na equipe/processo, gerando desmotivação e comportamento defensivo (ex: guardar cópias locais "por garantia").
- Perda de conhecimento: as decisões técnicas tomadas durante os 3 dias somem junto com o código.
- Efeito dominó no time: atrito interpessoal desnecessário entre Marcos e Juliana.
- Módulo crítico exposto: qualquer instabilidade no módulo de **pagamentos** tem risco direto sobre a operação financeira da empresa.

**3. Solução Git:** Para cada problema identificado, explique como o Git resolveria:

| Problema Identificado | Como o Git Resolve |
|---|---|
| Ex: Não saber qual versão é a correta | Existe uma branch `main` que é a fonte única de verdade |
| Perda de trabalho por sobrescrita | Cada commit fica registrado no histórico; nada é perdido — dá para reverter (`git revert`, `git log`) e recuperar qualquer versão anterior |
| Ausência de fonte única de verdade | A branch `main` (ou `master`) é a fonte única de verdade; todos sabem exatamente onde está o código oficial |
| Impossibilidade de rastrear mudanças | Cada commit tem autor, data/hora e mensagem descrevendo o que e por que foi alterado (`git log`, `git blame`) |
| Nenhum mecanismo de merge/colaboração paralela | Branches permitem trabalho isolado e simultâneo; `git merge`/pull request combinam as mudanças de forma controlada, com detecção automática de conflitos |
| Convenção de nomes como controle de versão | O versionamento é automático e nativo da ferramenta — não depende de disciplina manual para nomear arquivos |

**4. Prevenção:** Que regras a equipe deveria estabelecer ao adotar Git? (pense em convenções de branches, commits, etc.)

**Resposta:**

1. **Convenção de branches** — `main`/`master` sempre estável e protegida; features em branches próprias (ex: `feature/filtro-data`, `fix/pagamentos`), nunca direto na main.
2. **Convenção de commits** — mensagens claras e padronizadas (ex: Conventional Commits: `fix:`, `feat:`, `docs:`).
3. **Proibir push direto na main** — mudanças só entram via Pull Request, com revisão de código obrigatória.
4. **Commits pequenos e frequentes** — facilita identificar/reverter problemas.
5. **`.gitignore` configurado** — evita versionar arquivos que não deveriam estar no repositório.
6. **Pull antes de começar a trabalhar** — reduz conflitos.
7. **Nunca versionar arquivos zipados como "controle de versão"** — eliminar a prática de `arquivo_final_v2.zip`.

---

## Parte 2 — "Funciona na Minha Máquina" (Inconsistência de Ambientes)

### Cenário

Leia o relatório de incidente da Juliana:

> **De:** Juliana Santos, Desenvolvedora Sênior — TechNova  
> **Para:** Equipe de Platform Engineering  
> **Assunto:** URGENTE — API falhando em múltiplos ambientes

> Na terça-feira, terminei a feature de listagem de pedidos com filtro por data. Testei localmente: **funcionou perfeitamente**. Fiz push para o repositório.
>
> O Rafael fez pull e recebeu: `Error: Cannot find module 'date-fns'`
>
> O Marcos conseguiu instalar, mas ao rodar: `TypeError: date.toLocaleString is not a function`
>
> No servidor de staging: incompatibilidade de `libssl` com `bcrypt`.
>
> **Resultado:**
> - Meu laptop (macOS, Node 20.11): ✅ Funciona
> - Rafael (Ubuntu, Node 18.12): ❌ Falha na instalação
> - Marcos (Windows 11, Node 20.9): ❌ Comportamento diferente
> - Servidor staging (Ubuntu 22.04, Node 18.17): ❌ Incompatibilidade de libs

### Discussão em Grupo

**5. Causa Raiz:** Identifique as 3 categorias de diferenças entre ambientes que causaram as falhas no relatório da Juliana.

**Resposta:**

1. **Dependências de aplicação (pacotes)** — o módulo `date-fns` não estava instalado corretamente em todas as máquinas.
2. **Versão do runtime (Node.js)** — Node 20.11 (Juliana) vs 18.12 (Rafael) vs 20.9 (Marcos) vs 18.17 (staging), explicando o comportamento distinto de `date.toLocaleString`.
3. **Bibliotecas/dependências do sistema operacional** — incompatibilidade de `libssl` com `bcrypt` no staging, um problema de nível de SO.

**6. Requisitos da Solução:** O que uma solução ideal deveria garantir? Complete:
- **Isolamento:** o ambiente da aplicação fica encapsulado e separado do SO host e de outros projetos.
- **Reprodutibilidade:** o mesmo ambiente pode ser recriado de forma idêntica em qualquer máquina.
- **Portabilidade:** o ambiente roda da mesma forma independente do SO ou hardware do host.
- **Leveza:** consome poucos recursos e inicia rapidamente, permitindo vários ambientes na mesma máquina.

**7. Container vs. VM:** Se alguém sugerisse "vamos dar uma VM para cada dev", quais seriam os prós e contras comparados a containers?

| Aspecto | VM | Container |
|---|---|---|
| Tempo de inicialização | Minutos (boot de SO completo) | Segundos (compartilha o kernel do host) |
| Uso de disco | Alto — cada VM carrega um SO completo (GBs) | Baixo — só a aplicação e dependências (MBs) |
| Consumo de memória | Alto — cada VM reserva RAM para seu próprio kernel/SO | Baixo — processos isolados compartilhando o kernel do host |
| Facilidade de versionamento | Difícil — imagens de VM são grandes e pesadas | Fácil — imagens Docker em camadas, versionáveis via Dockerfile/registry |
| Densidade no servidor | Baixa — poucas VMs por máquina física | Alta — dezenas/centenas de containers na mesma máquina |

**8. A Conexão:** Como Git e Docker juntos resolvem os dois problemas da TechNova? Descreva o fluxo completo que um novo desenvolvedor seguiria para ter a API rodando.

**Resposta:**

Git garante que o **código** esteja sempre correto e rastreável (fonte única de verdade); Docker garante que o **ambiente** onde esse código roda seja sempre idêntico, não importa a máquina. Juntos, eliminam tanto o caos de versões quanto o "funciona na minha máquina".

**Fluxo completo de um novo desenvolvedor:**

1. **Clonar o repositório** — `git clone` traz o código na versão exata da `main`, incluindo `Dockerfile` e `docker-compose.yml` versionados junto com o código.
2. **Construir a imagem** — `docker build` (ou `docker compose build`) lê o `Dockerfile`, que especifica a versão do Node, dependências de sistema (`libssl`, etc.) e pacotes da aplicação (`date-fns` incluso).
3. **Subir o ambiente** — `docker compose up` inicia a API dentro do container, já com todas as dependências corretas, isolado do SO do host.
4. **Desenvolver com isolamento** — o dev cria uma branch (`git checkout -b feature/...`), faz alterações e testa localmente sabendo que o container reproduz fielmente staging/produção.
5. **Commitar e enviar** — `git commit` + `git push`, seguido de Pull Request revisado pela equipe antes do merge na `main`.
6. **Deploy consistente** — a mesma imagem Docker testada localmente é a que vai para staging/produção.

Resultado: qualquer pessoa da equipe roda `git clone` + `docker compose up` e tem a API funcionando de forma idêntica em minutos.

---

## Parte 3 — Síntese

### Proposta para o CTO

Com base nas discussões, cada grupo deve redigir uma proposta de **3-5 linhas** para o CTO com:

1. O que vocês implementarão (ferramentas)
2. O problema que cada ferramenta resolve
3. O resultado esperado para a equipe

> **Modelo:**
> "Carlos, propomos implementar __________ para resolver __________. Com isso, a equipe da TechNova poderá __________ e nunca mais __________."

**Resposta:**

> Carlos, propomos implementar **Git como sistema de controle de versão** para resolver **a perda de trabalho e a ausência de uma fonte única de verdade no código**, e **Docker como ferramenta de containerização** para resolver **a inconsistência de ambientes entre as máquinas dos desenvolvedores e o servidor de staging**. Com isso, a equipe da TechNova poderá **colaborar em paralelo com segurança, rastrear todo o histórico de mudanças e rodar a aplicação de forma idêntica em qualquer máquina**, e nunca mais **perder dias de trabalho por sobrescrita de arquivos ou perder horas depurando erros que só acontecem em determinado ambiente**.

---

## Critérios de Avaliação

| Critério | Peso |
|----------|:---:|
| Participação ativa na discussão | 30% |
| Identificação correta dos problemas | 20% |
| Qualidade das soluções propostas | 25% |
| Conexão entre Git e Docker na proposta | 15% |
| Clareza na apresentação oral | 10% |

---

## Formato

- **Duração:** 30 minutos (incluído no Bloco 1 da aula)
- **Grupos:** 3-4 pessoas
- **Entrega:** Não há entrega formal — a avaliação é pela participação e qualidade da discussão

---

*Após a discussão, passaremos para o conteúdo teórico de Git (Bloco 2), seguido do laboratório hands-on.*
