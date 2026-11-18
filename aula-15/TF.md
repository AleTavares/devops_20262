# Trabalho de Fixação (TF) — Aula 15: Apresentação Final e Entrega do Portfólio

## Entrega

O TF desta aula é a **entrega final do desafio técnico** ([github.com/AleTavares/implement_Moodle](https://github.com/AleTavares/implement_Moodle)), que corresponde à **Parte Prática da Prova do Segundo Bimestre**. O relatório completo é registrado neste repositório da disciplina via Pull Request.

> **Regra fundamental:** o repositório da disciplina recebe **somente o `entrega.md`**. Todo o código, módulos Terraform, screenshots, Spec do Kiro e demais evidências ficam no fork do `implement_Moodle`. O `entrega.md` aponta para eles com links. PRs que incluam arquivos além do `entrega.md` são bloqueados automaticamente.

---

## Informações de Entrega

| Item | Detalhe |
|------|---------|
| **Prazo** | No dia e horário definidos no calendário da disciplina |
| **Forma de entrega** | Pull Request (PR) para o repositório da disciplina |
| **Pasta de entrega no fork da disciplina** | `entregas/provaSegundoBi/RA/` (substitua RA pelo seu número de matrícula) |
| **Conteúdo do PR** | Apenas o arquivo `entrega.md` com links para as evidências no fork do projeto |
| **Arquivos do projeto e evidências** | No seu fork de `github.com/AleTavares/implement_Moodle` |

---

## O que fazer

### 1. Finalizar o fork do projeto (implement_Moodle)

Todos os entregáveis ficam no fork do `implement_Moodle`:

```bash
cd implement_Moodle
# desenvolva e finalize módulos Terraform, user_data.sh,
# docs/architecture-design.md, .kiro/specs/, screenshots/, etc.
git add .
git commit -m "feat: entrega final prova segundo bimestre"
git push origin main
```

**Onde ficam as evidências no fork:**
- Screenshots → `screenshots/` ou `docs/img/` no fork
- Spec do Kiro → `.kiro/specs/<nome-do-modulo>/` no fork
- Documento de arquitetura → `docs/architecture-design.md` no fork
- Resultado do `pytest -v` → screenshot salvo no fork

### 2. Registrar apenas o `entrega.md` neste repositório da disciplina

```bash
cd /caminho/para/seu-fork-da-disciplina
git checkout -b prova2/SEU-RA
mkdir -p entregas/provaSegundoBi/SEU-RA
# Crie o arquivo entrega.md com links para o fork do projeto
git add entregas/provaSegundoBi/SEU-RA/entrega.md
git commit -m "feat(prova2): entrega - SEU NOME (RA: SEU-RA)"
git push -u origin prova2/SEU-RA
```

Abra o Pull Request no GitHub com:
- **Título:** `[Prova P2] RA: SEU-RA - SEU NOME`
- **Base:** `main`
- **Compare:** `prova2/SEU-RA`

---

## Modelo do `entrega.md`

Preencha com **links** para as evidências que estão no fork do `implement_Moodle`:

```
# Entrega — Prova do Segundo Bimestre (Parte Prática)

**Aluno:** [Nome completo]
**RA:** [Número de matrícula]
**Data de entrega:** [Data]

## Fork do projeto

- URL: https://github.com/SEU-USUARIO/implement_Moodle
- Branch: [main ou nome da branch]
- Commit final: https://github.com/SEU-USUARIO/implement_Moodle/commit/HASH

## Evidências

> Todas as evidências estão no fork acima. Os links abaixo apontam para cada uma.

### Entregável 1 — Docker Local
- [ ] Screenshot do Moodle em localhost:8080: [link no fork]

### Entregável 2 — Terraform
- [ ] Módulo `networking`: [link para pasta no fork]
- [ ] Módulo `compute` (com user_data.sh): [link para pasta no fork]
- [ ] Módulo `database` (RDS privado): [link para pasta no fork]
- [ ] Screenshot terraform validate: [link no fork]
- [ ] Screenshot terraform plan sem erros: [link no fork]

### Entregável 3 — Documento de Arquitetura
- [ ] docs/architecture-design.md: [link direto no fork]

### Entregável 4 — CI/CD
- [ ] terraform-plan.yml: [link para o arquivo no fork]
- [ ] Screenshot ou link da execução no GitHub Actions: [link]

### Entregável 5 — Kiro e Kiro Workflows
- [ ] Spec do Kiro em .kiro/specs/: [link para a pasta no fork]
- [ ] Screenshot do Kiro Workflow: [link no fork]
- [ ] Descrição: [o que o workflow fez e como contribuiu — 2 a 5 linhas]

### Entregável 6 — Organização
- [ ] Screenshot pytest -v passando: [link no fork]
- [ ] Commits semânticos: [link para o histórico no fork]

## Relatório Final do Projeto

[Descreva em 10 a 30 linhas a jornada das semanas de desenvolvimento:
o que construiu, as decisões tomadas, as dificuldades superadas e o que aprendeu.]

## Ferramentas de IA utilizadas

[Indique as ferramentas usadas, incluindo o Kiro, ou "não utilizei"]
```

---

## Critérios de Avaliação

Consulte o arquivo `provas/prova-segundo-bimestre-pratica.md` para os critérios detalhados. Resumo:

| Critério | Peso |
|----------|:----:|
| Docker local funcional | 15% |
| Módulos Terraform (`networking`, `compute`, `database`) | 30% |
| Documento de arquitetura (`docs/architecture-design.md`) ⚠️ **eliminatório** | 15% |
| Workflow `terraform-plan.yml` | 15% |
| Uso do Kiro e Kiro Workflows | 15% |
| Organização e boas práticas | 10% |

> O arquivo `docs/architecture-design.md` é **eliminatório**: sua ausência zera a nota desta parte da prova.
