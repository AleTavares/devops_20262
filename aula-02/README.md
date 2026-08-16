# Aula 02 — Docker Compose e IA como Copiloto DevOps

## Objetivos de Aprendizagem

Ao final desta aula, o aluno será capaz de:

1. Compreender o papel do Docker Compose na orquestração de aplicações multi-container
2. Escrever um arquivo `docker-compose.yml` declarando serviços, redes, volumes e variáveis de ambiente
3. Configurar um ambiente de desenvolvimento local completo com API + banco de dados PostgreSQL
4. Utilizar volumes para persistência de dados e redes para comunicação entre containers
5. Compreender o papel da IA generativa como copiloto no fluxo de trabalho DevOps
6. Utilizar Kiro como IDE inteligente para gerar e validar configurações de infraestrutura
7. Aplicar boas práticas de prompting para obter resultados eficientes de assistentes de IA
8. Identificar casos de uso de IA ao longo do ciclo DevOps (desenvolvimento, CI/CD, monitoramento)

---

## Contexto Narrativo

> **O Resgate da TechNova — Episódio 2: "Um Container Não é Suficiente... Mas a IA Pode Ajudar"**

A containerização da API (Aula 01) foi um sucesso — agora qualquer desenvolvedor pode rodar a aplicação com `docker build` e `docker run`. O código está no Git e o ambiente está padronizado no Dockerfile. Mas um novo problema surgiu.

O backend da TechNova precisa de um **banco de dados PostgreSQL** para substituir o armazenamento em memória. Além disso, a equipe quer adicionar um **Redis** para cache no futuro. Rodar múltiplos containers manualmente ficou insustentável — são dezenas de flags, redes criadas na mão, e toda segunda-feira alguém esquece um parâmetro e tudo quebra.

Na reunião de quarta-feira, o CTO perdeu a paciência:

> "Toda vez que alguém novo entra no time, leva meio dia para subir o ambiente. Preciso de **um comando** para subir tudo. E outra coisa — ouvi falar de ferramentas de IA que aceleram a configuração de infraestrutura. Quero que a equipe explore isso também."

A líder da equipe de Platform Engineering sorriu:

> "Já temos a solução para os containers: **Docker Compose**. Um arquivo YAML que declara todos os serviços, redes e volumes. E sobre a IA — conheço o **Kiro**, um ambiente de desenvolvimento inteligente que pode nos ajudar a gerar e validar configurações. Vamos atacar os dois problemas hoje."

O desafio desta aula: transformar a orquestração manual em um `docker-compose.yml` declarativo **e** explorar como a IA pode ser nossa aliada no dia a dia de DevOps.

---

## Visão Geral da Aula



| Bloco | Atividade | Descrição |
|:---:|---|---|
| 1 | Revisão TA + Discussão | Discussão das questões do TA, esclarecimento de dúvidas sobre Docker Compose e IA |
| 2 | Conteúdo Teórico — Docker Compose | Orquestração declarativa, docker-compose.yml, redes, volumes, boas práticas |
| 3 | Laboratório Parte 1 — Docker Compose | Hands-on: ambiente completo com API + PostgreSQL |
| 4 | Conteúdo Teórico — IA no DevOps + Kiro | IA generativa, copiloto DevOps, Kiro, AWS Bedrock, limitações |
| 5 | Laboratório Parte 2 — IA como Copiloto | Hands-on: criar API REST completa do zero com Kiro Spec (requisitos → design → código), gerar Dockerfile e docker-compose.yml, testar os endpoints e fazer reflexão crítica sobre o uso de IA |
| 6 | Encerramento + Orientação TF | Resumo, orientações da Tarefa de Fixação, próximos passos |

---

## Pré-requisitos

Antes da aula, o aluno deve ter:

- [ ] **Docker Desktop** instalado e funcional ([download](https://www.docker.com/products/docker-desktop/))
- [ ] **Docker Compose** disponível (incluso no Docker Desktop)
- [ ] **Git** instalado e configurado (Aula 01)
- [ ] **Conta no GitHub** ativa (Aula 01)
- [ ] **VS Code** instalado ([download](https://code.visualstudio.com/))
- [ ] **Kiro** instalado ([download](https://kiro.dev/)) — ou acesso configurado conforme orientação do professor
- [ ] **Terminal** funcional (Git Bash no Windows, Terminal no macOS/Linux)
- [ ] Conceitos de Dockerfile e Docker dominados (Aula 01)

> **Verificar Docker Compose:**
> ```bash
> docker compose version
> ```
> Resultado esperado: `Docker Compose version v2.x.x`

---

## Entrega do Trabalho em Aula

O trabalho em aula vale **1 ponto na nota final** do semestre (contabilizado apenas ao final, com todos os trabalhos entregues).

### Onde entregar

Na **mesma pasta** da entrega do TF, no fork da disciplina:

```
entregas/aula-02/SEU-RA/trabalho-em-aula.md
```

### O que entregar

Um arquivo `trabalho-em-aula.md` com as respostas das atividades realizadas em sala (discussões, análises, tabelas preenchidas).

### Observações

- A entrega é **individual** — mesmo que a atividade tenha sido em grupo
- O arquivo pode ser adicionado no **mesmo PR** do TF ou em PR separado
- Entregas parciais (apenas algumas aulas) **não garantem o ponto**

---

## Estrutura de Arquivos desta Aula

| Arquivo | Descrição |
|---------|-----------|
| `README.md` | Este arquivo — visão geral da aula |
| `TA.md` | Trabalho Anterior — leitura prévia obrigatória (~60 min) |
| `trabalho-em-aula.md` | Atividade de discussão e demonstração em sala |
| `laboratorio-parte1.md` | Laboratório hands-on de Docker Compose (~120 min) |
| `laboratorio-parte2.md` | Laboratório hands-on de IA como Copiloto (~90 min) |
| `TF.md` | Trabalho de Fixação — entrega semanal via PR |
| `materiais-complementares.md` | Recursos adicionais para aprofundamento |

---

## Conexão com o Módulo

| Aula | Problema Resolvido | Artefato Principal |
|------|-------------------|----------|
| Aula 01 | Código se perdia + "funciona na minha máquina" | `.git/` + `Dockerfile` |
| **Aula 02** | **Orquestração manual + produtividade com IA** | **`docker-compose.yml` + workflow com Kiro** |

Ao final desta aula, a TechNova terá:

- ✅ Código versionado e rastreável (Git)
- ✅ Ambiente isolado e reproduzível (Docker)
- ✅ Infraestrutura local declarativa e automatizada (Docker Compose)
- ✅ Fluxo de trabalho assistido por IA (Kiro)

---

*Próxima etapa: Leitura do TA.md (Trabalho Anterior) como preparação para a aula.*
