# Relatório de Produção de TF
**Análise e Desenvolvimento de Sistemas**  
**2026.2**

* **Professor:** Alexandre da Costa Tavares Jr
* **Disciplina:** DevOps
* **Aula:** 1☐ 2☐ 3☐ 4☐ 5☐ 6☐ 7☐ 8☐ 9☐ 10☐ 11☐ 12☐ 13☐ 14☒ 15☐
* **Data da aula:** [Data da aula]
* **Título da aula:** Disaster Simulation, Code Review e Agente Bedrock

---

## Resumo da Atividade Aplicada

### Objetivo
Avançar no **Moodle Docker AWS Challenge** ([github.com/AleTavares/implement_Moodle](https://github.com/AleTavares/implement_Moodle)), com foco em finalizar a infraestrutura Terraform, implementar o workflow `terraform-plan.yml` e completar o documento de arquitetura — deixando o projeto pronto para a entrega final.

### Tarefa
Trabalhar no fork do `implement_Moodle` finalizando os três módulos Terraform (`networking`, `compute`, `database`) e garantindo que `terraform validate` e `terraform plan` executem sem erros. Implementar o workflow `terraform-plan.yml` que executa `terraform plan` a cada Pull Request, autenticando com as credenciais temporárias do Learner Lab (secrets `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`). Completar o documento `docs/architecture-design.md` com diagrama da arquitetura, descrição dos componentes, justificativas de segurança e estimativa de custo. Revisar o `.gitignore` garantindo que `.env`, `*.tfstate` e arquivos sensíveis não sejam commitados. Registrar o progresso com um commit no fork, preencher o relatório descrevendo o que foi feito e as dificuldades encontradas, e entregar via Pull Request no repositório da disciplina em `entregas/aula-14/RA/`.

---

*Obs: Este é um documento para registro das atividades praticadas em sala de aula junto da turma de Análise e Desenvolvimento de Sistemas, sejam dinâmicas, trabalhos, seminários ou atividades práticas.*
