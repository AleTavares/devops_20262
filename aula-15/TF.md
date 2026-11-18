# Trabalho de Fixação (TF) — Aula 15: Apresentação Final e Entrega do Portfólio

## Entrega

O TF desta aula é a **entrega final do desafio técnico** ([github.com/AleTavares/implement_Moodle](https://github.com/AleTavares/implement_Moodle)), que corresponde à **Parte Prática da Prova do Segundo Bimestre**. O relatório completo é registrado neste repositório da disciplina via Pull Request.

---

## Informações de Entrega

| Item | Detalhe |
|------|---------|
| **Prazo** | No dia e horário definidos no calendário da disciplina |
| **Forma de entrega** | Pull Request (PR) para o repositório da disciplina |
| **Pasta de entrega no fork da disciplina** | `entregas/provaSegundoBi/RA/` (substitua RA pelo seu número de matrícula) |
| **Conteúdo do PR** | Apenas o arquivo `entrega.md` com relatório completo e link do commit final |
| **Arquivos do projeto** | No seu fork de `github.com/AleTavares/implement_Moodle` |

### Como Entregar via Pull Request

1. Finalize o seu fork do `implement_Moodle` com todos os entregáveis possíveis
2. Faça o commit final no fork do projeto
3. No fork **deste repositório da disciplina**, crie a pasta `entregas/provaSegundoBi/SEU-RA/`
4. Adicione apenas o arquivo `entrega.md` (modelo abaixo)
5. Faça commit e push para o seu fork da disciplina
6. Abra um Pull Request para o repositório original da disciplina

---

## Modelo do arquivo `entrega.md`

```markdown
# Entrega — Prova do Segundo Bimestre (Parte Prática)

**Aluno:** [Nome completo]
**RA:** [Número de matrícula]
**Data de entrega:** [Data]

## Fork do projeto

- URL: https://github.com/SEU-USUARIO/implement_Moodle
- Commit final: https://github.com/SEU-USUARIO/implement_Moodle/commit/HASH

## Evidências

### Entregável 1 — Docker Local
- [ ] Moodle acessível em localhost:8080 (screenshot ou link)

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
- [ ] Workflow executando com sucesso na PR (screenshot ou link)

### Entregável 5 — Kiro e Kiro Workflows
- [ ] Spec do Kiro criada em `.kiro/specs/<modulo>/` (link)
- [ ] Screenshot do Kiro Workflow em execução ou concluído
- [ ] Descrição do que o workflow fez e como contribuiu

### Entregável 6 — Organização
- [ ] `.gitignore` cobrindo arquivos sensíveis
- [ ] `README.md` atualizado
- [ ] Commits semânticos
- [ ] Nenhuma credencial nos commits
- [ ] `pytest -v` passando (screenshot)

## Relatório Final do Projeto

[Descreva em 10 a 30 linhas a jornada completa das semanas de desenvolvimento:
o que você construiu, as decisões tomadas, as dificuldades superadas e o que aprendeu.]

## Ferramentas de IA utilizadas

[Indique as ferramentas usadas, incluindo o Kiro, ou "não utilizei"]
```

---

## Como Entregar via Pull Request

```bash
cd /caminho/para/seu-fork-da-disciplina
git checkout -b prova2/SEU-RA
mkdir -p entregas/provaSegundoBi/SEU-RA
# Crie o arquivo entrega.md com o modelo acima
git add entregas/provaSegundoBi/SEU-RA/entrega.md
git commit -m "feat(prova2): entrega - SEU NOME (RA: SEU-RA)"
git push -u origin prova2/SEU-RA
```

Abra o Pull Request no GitHub com:
- **Título:** `[Prova P2] RA: SEU-RA - SEU NOME`
- **Base:** `main`
- **Compare:** `prova2/SEU-RA`

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
