# Trabalho de Fixação (TF) — Aula 15: Apresentação Final e Entrega do Portfólio

## Entrega

O TF desta aula é a **entrega final do desafio técnico** ([github.com/AleTavares/implement_Moodle](https://github.com/AleTavares/implement_Moodle)) com o relatório completo de tudo o que foi desenvolvido ao longo das aulas 11 a 15. Esta entrega é a **Parte Prática da Prova do Segundo Bimestre** — veja o arquivo [`prova-segundo-bimestre-pratica.md`](../provas/prova-segundo-bimestre-pratica.md) para os critérios de avaliação detalhados.

---

## Informações de Entrega

| Item | Detalhe |
|------|---------|
| **Prazo** | No dia e horário definidos no calendário da disciplina |
| **Forma de entrega** | Pull Request (PR) para o repositório da disciplina |
| **Pasta de entrega no fork** | `entregas/provaSegundoBi/RA/` (substitua RA pelo seu número de matrícula) |
| **Conteúdo do PR** | Apenas o arquivo `entrega.md` com relatório completo e link do commit final |

---

## O que fazer

1. Finalize o seu fork do `implement_Moodle` com todos os entregáveis possíveis dentro do prazo.
2. Faça um commit final com o estado da solução.
3. Crie o arquivo `entrega.md` na pasta de entrega conforme o modelo completo da prova prática (veja `prova-segundo-bimestre-pratica.md`).

---

## Modelo do arquivo `entrega.md`

```markdown
# Entrega — Prova do Segundo Bimestre (Parte Prática)

**Aluno:** [Nome completo]
**RA:** [Número de matrícula]
**Data de entrega:** [Data]

## Fork do Desafio

- URL do fork: https://github.com/SEU-USUARIO/implement_Moodle
- Commit final: https://github.com/SEU-USUARIO/implement_Moodle/commit/HASH

## Evidências

### Entregável 1 — Docker Local
- [ ] Moodle acessível em localhost:8080 (screenshot anexado ou link)

### Entregável 2 — Terraform
- [ ] Módulo `networking` implementado
- [ ] Módulo `compute` implementado (com `user_data.sh`)
- [ ] Módulo `database` implementado (RDS privado)
- [ ] `terraform validate` passou (screenshot)
- [ ] `terraform plan` executado sem erros (screenshot)

### Entregável 3 — Documento de Arquitetura
- [ ] `docs/architecture-design.md` presente no fork
- [ ] Diagrama incluído
- [ ] Justificativas de segurança documentadas
- [ ] Estimativa de custo incluída

### Entregável 4 — CI/CD
- [ ] `terraform-plan.yml` implementado
- [ ] Workflow executando com sucesso na PR (screenshot ou link da execução)

### Entregável 5 — Organização
- [ ] `.gitignore` cobrindo arquivos sensíveis
- [ ] `README.md` atualizado
- [ ] Commits semânticos
- [ ] Nenhuma credencial nos commits
- [ ] `pytest -v` passando (screenshot)

## Relatório Final do Projeto

[Descreva em 10 a 30 linhas a jornada completa: o que você construiu, as principais
decisões que tomou, as dificuldades que enfrentou e como as resolveu, e o que aprendeu
ao longo das aulas 11 a 15 trabalhando neste desafio.]

## Observações

[Descreva pontos que merecem atenção do professor, entregas parciais e o motivo.]

## Ferramentas de IA utilizadas

[Indique as ferramentas usadas ou "não utilizei"]
```

---

## Critérios de Avaliação

Consulte o arquivo `prova-segundo-bimestre-pratica.md` para os critérios detalhados. Resumo:

| Critério | Peso |
|----------|:----:|
| Docker local funcional | 20% |
| Módulos Terraform (`networking`, `compute`, `database`) | 35% |
| Documento de arquitetura (`docs/architecture-design.md`) | 20% |
| Workflow `terraform-plan.yml` | 15% |
| Organização e boas práticas | 10% |

> O arquivo `docs/architecture-design.md` é **eliminatório**: sua ausência zera a nota desta parte da prova.
