# Trabalho de Fixação (TF) — Aula 13: Novo Microserviço com Pipeline End-to-End

## Entrega

O TF desta aula é um **push no seu fork do desafio técnico** ([github.com/AleTavares/implement_Moodle](https://github.com/AleTavares/implement_Moodle)) com o progresso realizado até aqui, acompanhado de um relatório registrado neste repositório da disciplina via Pull Request.

---

## Informações de Entrega

| Item | Detalhe |
|------|---------|
| **Prazo** | 1 semana a partir da data da aula |
| **Forma de entrega** | Pull Request (PR) para o repositório da disciplina |
| **Pasta de entrega no fork da disciplina** | `entregas/aula-13/RA/` (substitua RA pelo seu número de matrícula) |
| **Conteúdo do PR** | Apenas o arquivo `entrega.md` com o relatório e o link do commit |
| **Arquivos do projeto** | No seu fork de `github.com/AleTavares/implement_Moodle` |

### Como Entregar via Pull Request

1. Trabalhe no seu fork do `implement_Moodle` e faça um commit com o progresso da semana
2. No fork **deste repositório da disciplina**, crie a pasta `entregas/aula-13/SEU-RA/`
3. Adicione apenas o arquivo `entrega.md` (modelo abaixo)
4. Faça commit e push para o seu fork da disciplina
5. Abra um Pull Request para o repositório original da disciplina

---

## Modelo do arquivo `entrega.md`

```markdown
# Entrega — Aula 13 (TF)

**Aluno:** [Seu nome completo]
**RA:** [Seu RA]
**Data:** [Data da entrega]

## Fork do projeto

- URL: https://github.com/SEU-USUARIO/implement_Moodle
- Commit desta semana: https://github.com/SEU-USUARIO/implement_Moodle/commit/HASH

## O que foi feito nesta aula

[Descreva em 5 a 15 linhas o que você avançou no projeto.
Inclua: o que tentou, o que funcionou, o que ainda não está pronto e qual é o próximo passo.]

## Dificuldades encontradas

[Descreva pelo menos uma dificuldade técnica ou conceitual que encontrou e como abordou o problema.]
```

---

## Como Entregar via Pull Request

```bash
cd /caminho/para/seu-fork-da-disciplina
git checkout -b entregas/aula-13/SEU-RA
mkdir -p entregas/aula-13/SEU-RA
# Crie o arquivo entrega.md com o modelo acima
git add entregas/aula-13/SEU-RA/entrega.md
git commit -m "feat(aula-13): entrega TF - SEU NOME (RA: SEU-RA)"
git push -u origin entregas/aula-13/SEU-RA
```

Abra o Pull Request no GitHub com:
- **Título:** `[Aula 13] RA: SEU-RA - SEU NOME`
- **Base:** `main`
- **Compare:** `entregas/aula-13/SEU-RA`

---

## Critérios de Avaliação

| Critério | Peso |
|----------|:----:|
| Commit presente no fork do projeto com progresso real | 50% |
| Relatório descrevendo o que foi feito com clareza | 30% |
| Dificuldades relatadas com honestidade e detalhamento | 20% |

> Entregas parciais são aceitas e valorizadas. Um relato honesto de dificuldades vale mais do que um progresso exagerado ou copiado.
