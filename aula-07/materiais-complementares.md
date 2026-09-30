# Aula 07 — Materiais Complementares

> Recursos para aprofundar os conceitos desta aula: **resolução de problemas complexos**, **decomposição**, **Harness** e **Spec-Driven Development** com IA. Os materiais estão organizados do mais simples ao mais avançado.

---

## Dividir para Conquistar (Decomposição de Problemas)

### Para começar (linguagem acessível)

- [Decomposition — BBC Bitesize (Computational Thinking)](https://www.bbc.co.uk/bitesize/topics/z7tp34j/articles/zqrq7ty) — Explicação simples e visual do que é decompor um problema
- [Divide and Conquer — GeeksforGeeks](https://www.geeksforgeeks.org/divide-and-conquer-algorithm-introduction/) — O conceito clássico da computação, com exemplos
- [Como resolver problemas grandes quebrando em pequenos (busca)](https://www.youtube.com/results?search_query=decomposi%C3%A7%C3%A3o+de+problemas+programa%C3%A7%C3%A3o) — Vídeos em português sobre decomposição

### Pensamento computacional

- **Pensamento Computacional** — os 4 pilares: **decomposição**, reconhecimento de padrões, abstração e algoritmos. A decomposição é o primeiro e mais importante para esta aula.
- [Computational Thinking — Google for Education](https://edu.google.com/resources/programs/exploring-computational-thinking/) — Recursos sobre pensamento computacional

---

## Trabalhando com IA como Copiloto

### Prompt Engineering (escrever bons pedidos para a IA)

- [Prompt Engineering para Desenvolvedores — DeepLearning.AI](https://www.deeplearning.ai/short-courses/chatgpt-prompt-engineering-for-developers/) — Curso curto e gratuito (com legendas)
- [Guia de Prompt Engineering (OpenAI)](https://platform.openai.com/docs/guides/prompt-engineering) — Boas práticas para escrever prompts
- [Anthropic — Prompt Engineering Overview](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview) — Guia de como estruturar pedidos para IA

> **Ligação com a aula:** um bom prompt é, na prática, **um pedido pequeno e específico** — exatamente o que a decomposição produz.

### Alucinação de IA (o que é e como evitar)

- [What are AI hallucinations? — IBM](https://www.ibm.com/topics/ai-hallucinations) — Explicação clara sobre o fenômeno
- **Regra prática:** quanto menor e mais claro o pedido, menor a chance de alucinação. Sempre **valide** o que a IA produz.

---

## Spec-Driven Development e Kiro

- [Kiro — Documentação Oficial](https://kiro.dev/docs/) — Como usar o Kiro, incluindo o modo Spec
- [Kiro — Specs](https://kiro.dev/docs/specs/) — Como funciona o fluxo Requisitos → Design → Tarefas
- **Dica:** o modo Spec do Kiro é a decomposição transformada em ferramenta. Use-o sempre que o problema parecer grande.

### O conceito de "Harness" (guiar a IA)

- O termo **harness** (arreio) aparece muito no contexto de **agentes de IA** e ferramentas que "envolvem" o modelo com estrutura, contexto e regras.
- **Ideia central:** a IA é poderosa, mas precisa de estrutura ao redor para trabalhar de forma confiável — contexto, etapas claras, limites e pontos de validação.

---

## Node.js e Express (tecnologia do laboratório)

> O laboratório usa Node.js + Express só como "algo concreto" para a IA construir. Você **não precisa** ser especialista — mas se quiser entender melhor:

- [Node.js — Site Oficial](https://nodejs.org/) — Download e documentação
- [Express — Guia de Início Rápido](https://expressjs.com/pt-br/starter/hello-world.html) — "Hello World" em português
- [O que é uma API REST? (explicação simples)](https://www.redhat.com/pt-br/topics/api/what-is-a-rest-api) — Conceito de rotas, GET/POST, etc.
- [O que é curl? Como testar uma API](https://www.youtube.com/results?search_query=como+testar+api+com+curl) — Vídeos sobre testar rotas com `curl`

---

## Livros e Leituras (para quem quer ir além)

1. **A Mente Organizada** — Daniel Levitin — sobre como o cérebro lida com complexidade e organização
2. **Pense em Sistemas** — Donella Meadows — como enxergar problemas complexos em partes
3. **The Pragmatic Programmer** — Hunt & Thomas — clássico sobre resolver problemas de forma incremental
4. **Divide and Conquer** — conceito presente em qualquer bom livro de algoritmos e estrutura de dados

---

## Resumo: as 3 ideias para levar da aula

| Ideia | Em uma frase |
|-------|--------------|
| **Decomposição** | Todo problema grande é uma soma de problemas pequenos. |
| **Harness** | A IA trabalha melhor guiada por contexto, estrutura e validação. |
| **Spec-Driven** | Planejar (Requisitos → Design → Tarefas) antes de codar evita retrabalho e alucinação. |

---

## Preparação para o Módulo 3

O Módulo 3 (CI/CD e Automação) vai reunir tudo que você aprendeu. A habilidade de **decompor problemas** desta aula será usada o tempo todo — pipelines de CI/CD são, na essência, um problema grande dividido em etapas pequenas e automatizadas.

### O que revisar antes do Módulo 3:

- **Git:** branches, PRs, merges (Módulo 1)
- **Docker:** build, imagens (Módulo 1)
- **Decomposição e Spec-Driven:** esta aula
- **Kiro:** uso como copiloto (Aulas 02 e 07)
