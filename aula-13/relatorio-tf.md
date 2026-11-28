# Relatório de Produção de TF
**Análise e Desenvolvimento de Sistemas**  
**2026.2**

* **Professor:** Alexandre da Costa Tavares Jr
* **Disciplina:** DevOps
* **Aula:** 1☐ 2☐ 3☐ 4☐ 5☐ 6☐ 7☐ 8☐ 9☐ 10☐ 11☐ 12☐ 13☒ 14☐ 15☐
* **Data da aula:** [Data da aula]
* **Título da aula:** Novo Microserviço com Pipeline End-to-End

---

## Resumo da Atividade Aplicada

### Objetivo
Avançar no **Moodle Docker AWS Challenge** ([github.com/AleTavares/implement_Moodle](https://github.com/AleTavares/implement_Moodle)), com foco em aprofundar os módulos Terraform, implementar o `user_data.sh` para automação do deploy na EC2 e evoluir o documento de arquitetura.

### Tarefa
Trabalhar no fork do `implement_Moodle` desenvolvendo o módulo `compute`: criar o script `user_data.sh` que instala o Docker na EC2 e sobe o Moodle automaticamente no boot via `docker compose up -d`, passando as variáveis de ambiente do banco com segurança (sem expor senhas no código). Avançar nos módulos `networking` e `database`, garantindo que `terraform validate` e `terraform plan` executem sem erros. Atualizar o documento `docs/architecture-design.md` com diagrama da arquitetura e descrição dos componentes. Executar `pytest -v` na pasta `tests/` para verificar a conformidade do repositório. Registrar o progresso com um commit no fork, preencher o relatório descrevendo o que foi feito e as dificuldades encontradas, e entregar via Pull Request no repositório da disciplina em `entregas/aula-13/RA/`.

---

*Obs: Este é um documento para registro das atividades praticadas em sala de aula junto da turma de Análise e Desenvolvimento de Sistemas, sejam dinâmicas, trabalhos, seminários ou atividades práticas.*
