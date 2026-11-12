# Prova do Segundo Bimestre — DevOps 2026.2

**Disciplina:** DevOps  
**Curso:** Análise e Desenvolvimento de Sistemas — UniFAAT  
**Professor:** Alexandre da Costa Tavares Jr  
**Semestre:** 2026.2

---

## Estrutura da Prova

A prova do segundo bimestre é composta de **duas partes**, cada uma valendo **50% da nota (5,0 pontos)**.

| Parte | Arquivo | Formato | Valor |
|-------|---------|---------|:-----:|
| Teórica | [`prova-segundo-bimestre-teorica.md`](prova-segundo-bimestre-teorica.md) | 7 questões de múltipla escolha + 3 dissertativas | 5,0 pts |
| Prática | [`prova-segundo-bimestre-pratica.md`](prova-segundo-bimestre-pratica.md) | Desafio técnico individual | 5,0 pts |

---

## Parte Teórica

Abrange o conteúdo das **aulas 08 a 15**: GitHub Actions, Amazon ECR, Blue/Green Deployment, Canary Deployment, Expand-Contract, Chaos Engineering, RTO e boas práticas de containerização com Docker.

### Distribuição de pontos

| Seção | Qtd | Valor unitário | Total |
|-------|:---:|:--------------:|:-----:|
| Múltipla escolha | 7 | até 0,4 pt | até 2,8 pts |
| Dissertativas | 3 | 0,3 a 0,8 pt | 2,2 pts |
| **Total** | | | **5,0 pts** |

As questões dissertativas são baseadas diretamente no desafio técnico da parte prática — recomenda-se ler o repositório [github.com/AleTavares/implement_Moodle](https://github.com/AleTavares/implement_Moodle) antes de responder.

---

## Parte Prática

Desafio técnico individual baseado no repositório template **Moodle Docker AWS Challenge**:  
[github.com/AleTavares/implement_Moodle](https://github.com/AleTavares/implement_Moodle)

O aluno deve fazer um fork do repositório e entregar os seguintes itens:

| # | Entregável | Peso |
|:-:|-----------|:----:|
| 1 | Ambiente Docker local validado (`docker compose up -d`) | 20% |
| 2 | Infraestrutura Terraform completa (módulos `networking`, `compute`, `database`) | 35% |
| 3 | Documento de arquitetura (`docs/architecture-design.md`) ⚠️ **eliminatório** | 20% |
| 4 | Workflow `terraform-plan.yml` implementado e funcionando | 15% |
| 5 | Organização, `.gitignore`, commits semânticos e `pytest` passando | 10% |

A entrega é feita via Pull Request no repositório da disciplina, em `entregas/provaSegundoBi/SEU-RA/`, contendo apenas o arquivo `entrega.md` com os links e evidências.

---

## Entrega

| Item | Detalhe |
|------|---------|
| **Pasta no fork da disciplina** | `entregas/provaSegundoBi/SEU-RA/` |
| **Arquivo a entregar** | `entrega.md` (modelo no arquivo da prova prática) |
| **Título do PR** | `[Prova P2] RA: SEU-RA - SEU NOME` |
| **Repositório do projeto** | fork pessoal de `github.com/AleTavares/implement_Moodle` |

> O arquivo `docs/architecture-design.md` no fork do projeto é **eliminatório**: sua ausência zera a nota da parte prática, independentemente da pontuação nos demais critérios.

---

## Regras Gerais

1. A prova é **individual**.
2. Consulta à documentação oficial, materiais das aulas e código próprio do curso é **permitida**.
3. Copiar solução de colegas **não é permitido**. O aluno deve conseguir explicar o que entregou.
4. Uso de ferramentas de IA é **permitido** — informe no `entrega.md` e revise o que for gerado.
5. Não inclua credenciais AWS, senhas, tokens, `.env` reais ou estado Terraform no repositório.
6. Abra apenas **um Pull Request** de entrega.

---

## Arquivos nesta pasta

| Arquivo | Descrição |
|---------|-----------|
| `prova-segundo-bimestre-teorica.md` | Enunciado completo da parte teórica |
| `prova-segundo-bimestre-pratica.md` | Enunciado completo da parte prática |
| `gabarito-segundo-bimestre-teorica.md` | Gabarito com critérios de correção *(uso restrito — professor)* |
| `prova-primeiro-bimestre.md` | Prova do primeiro bimestre (referência) |
