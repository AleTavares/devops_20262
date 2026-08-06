# Aula 01 — Fundamentos de Git e Docker

## Objetivos de Aprendizagem

Ao final desta aula, o aluno será capaz de:

1. Compreender o que é um Sistema de Controle de Versão (VCS) e por que ele é essencial no desenvolvimento de software moderno
2. Diferenciar sistemas de controle de versão centralizados e distribuídos, identificando as vantagens do modelo distribuído
3. Executar o fluxo básico do Git: inicializar repositórios, adicionar arquivos ao staging, criar commits e visualizar o histórico
4. Trabalhar com branches, realizar merges e interagir com repositórios remotos (push, pull, clone)
5. Compreender o conceito de containers e como eles resolvem o problema "funciona na minha máquina"
6. Diferenciar containers de máquinas virtuais, identificando as vantagens da containerização
7. Construir imagens Docker a partir de um Dockerfile e gerenciar containers com os comandos essenciais
8. Publicar e consumir imagens do Docker Hub, entendendo o conceito de registries

---

## Contexto Narrativo

> **O Resgate da TechNova — Episódio 1: Do Caos ao Container**

A TechNova é uma startup promissora que desenvolveu uma API de gerenciamento de pedidos. O negócio está crescendo, mas nos bastidores reina o caos absoluto. Os desenvolvedores trabalham enviando código por e-mail e pen drives. Toda semana alguém sobrescreve o trabalho de outro colega. Na sexta-feira passada, a versão que estava em produção foi perdida porque ninguém sabia qual era a cópia "oficial".

Mas esse não é o único problema. Quando finalmente conseguem compartilhar código (mesmo que por e-mail), surge a segunda catástrofe: **"Funciona na minha máquina!"**. A desenvolvedora Juliana termina uma feature que roda perfeitamente no laptop dela. O Rafael faz download e... **erro**. O Marcos tenta no computador dele... **outro erro diferente**. Juliana usa Node.js 20, Rafael tem Node.js 18, e o servidor de staging roda uma versão completamente diferente de tudo.

O CTO da TechNova, desesperado, acabou de contratar uma equipe de **Platform Engineering** — vocês — para resgatar a empresa desse desastre duplo. A primeira missão é clara e ambiciosa: em um único sprint, resolver **dois problemas fundamentais** simultaneamente:

1. **Estabelecer controle de versão** — para nunca mais perder código nem sobrescrever trabalho alheio
2. **Containerizar a aplicação** — para garantir que o código rode de forma idêntica em qualquer lugar

Hoje vocês começam a construir a fundação de tudo que virá depois: CI/CD, infraestrutura como código, deploys automatizados. Mas primeiro, precisamos dominar o Git e o Docker — as duas ferramentas que transformam caos em ordem.

---

## Visão Geral da Aula

**Duração total:** ~5 horas (300 minutos)

| Bloco | Atividade | Duração | Descrição |
|:---:|---|:---:|---|
| 1 | Revisão TA + Discussão | 30 min | Discussão das questões do TA, esclarecimento de dúvidas sobre a leitura prévia |
| 2 | Conteúdo Teórico — Git | 50 min | VCS, Git fundamentals, branches, remotes, boas práticas |
| 3 | Laboratório Parte 1 — Git | 120 min | Hands-on: configuração, repositório, commits, branches, GitHub |
| 4 | Conteúdo Teórico — Docker | 50 min | Containers vs VMs, Dockerfile, imagens, comandos essenciais |
| 5 | Laboratório Parte 2 — Docker | 120 min | Hands-on: Dockerfile, build, run, gerenciamento, versionamento |
| 6 | Encerramento + Orientação TF | 15 min | Resumo, orientações da Tarefa de Fixação, próximos passos |

---

## Pré-requisitos

Antes da aula, o aluno deve ter:

- [ ] **Git** instalado na máquina ([download](https://git-scm.com/downloads))
- [ ] **Docker Desktop** instalado e funcional ([download](https://www.docker.com/products/docker-desktop/))
- [ ] **Conta no GitHub** ativa ([criar conta](https://github.com/signup))
- [ ] **VS Code** instalado ([download](https://code.visualstudio.com/))
- [ ] **Terminal** funcional (Git Bash no Windows, Terminal no macOS/Linux)

---

## Estrutura de Arquivos desta Aula

| Arquivo | Descrição |
|---------|-----------|
| `README.md` | Este arquivo — visão geral da aula |
| `TA.md` | Trabalho Anterior — leitura prévia obrigatória |
| `trabalho-em-aula.md` | Atividade de discussão em sala |
| `laboratorio-parte1.md` | Laboratório hands-on de Git (~120 min) |
| `laboratorio-parte2.md` | Laboratório hands-on de Docker (~120 min) |
| `TF.md` | Trabalho de Fixação — entrega semanal |
| `materiais-complementares.md` | Recursos adicionais para aprofundamento |

---

*Próxima etapa: Leitura do TA.md (Trabalho Anterior) como preparação para a aula.*
