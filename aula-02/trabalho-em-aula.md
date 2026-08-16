# Trabalho em Aula — Docker Compose e IA como Copiloto

**Duração:** ~30 minutos (Bloco 1 da aula)

---

## Pontuação

Este trabalho vale **1 ponto na nota final do semestre** (contabilizado apenas ao final, com **todos** os trabalhos em aula entregues).

---

## Contexto

Vocês acabaram de ler o e-mail do Rafael pedindo ajuda com a orquestração multi-container. Além disso, o CTO mencionou que quer explorar ferramentas de IA para acelerar o trabalho de infraestrutura. Vamos discutir os dois temas antes de partir para a prática.

---

## Parte 1 — Análise do Problema Multi-Container (15 min)

### Atividade em Grupo (3-4 pessoas)

#### Etapa A: Identificação dos Problemas (5 min)

Analisem o e-mail do Rafael e listem:

1. **Quais são os 5 problemas** que ele mencionou com a abordagem manual?
2. Para cada problema, classifiquem como:
   - 🔴 Crítico (pode causar perda de dados ou parada)
   - 🟡 Moderado (causa retrabalho ou demora)
   - 🟢 Menor (incômodo mas contornável)

#### Etapa B: Design da Solução (10 min)

Em grupo, esbocem (no quadro ou papel) como o `docker-compose.yml` resolveria **cada um** dos problemas do Rafael:

| Problema do Rafael | Recurso do Docker Compose que resolve |
|-------------------|--------------------------------------|
| 4 comandos complexos | ? |
| Ninguém lembra a ordem | ? |
| Senhas espalhadas | ? |
| Dados se perdem | ? |
| Novos devs sofrem | ? |

**Desafio bônus:** Desenhem a arquitetura (containers, redes, volumes) que o `docker-compose.yml` deveria declarar.

---

## Parte 2 — Demonstração: Kiro como Copiloto DevOps (15 min)

### Demonstração ao Vivo pelo Professor

O professor demonstrará ao vivo como usar Kiro para gerar um `docker-compose.yml` baseado na demanda do Rafael.

#### Prompt usado na demonstração:

> "Crie um docker-compose.yml para uma aplicação Node.js com Express que se conecta a um banco PostgreSQL 15. A API roda na porta 3000 e precisa das variáveis DB_HOST, DB_PORT, DB_NAME, DB_USER e DB_PASSWORD. Use volume nomeado para o PostgreSQL, rede bridge customizada, e configure depends_on."

#### Durante a demonstração, observem:

1. **O que o Kiro gerou corretamente?**
   - Estrutura do YAML
   - Serviços declarados
   - Redes e volumes

2. **O que precisou de ajuste?**
   - Versões de imagens
   - Variáveis de ambiente faltando
   - Boas práticas não seguidas (ex: senhas hardcoded)

3. **O que a IA não fez mas deveria?**
   - `.env` separado?
   - `.env.example`?
   - Healthchecks?
   - Restart policies?

### Discussão Pós-Demonstração

Após a demonstração, discutam em classe:

1. **Velocidade vs Qualidade:** O Kiro gerou o arquivo mais rápido que escrever manualmente? A qualidade foi equivalente?

2. **Quando confiar:** Em quais partes do output vocês confiariam imediatamente? Em quais fariam verificação extra?

3. **Cenário real:** Se vocês fossem usar Kiro no dia a dia, qual seria o workflow ideal?
   - Gerar → Revisar → Ajustar → Testar?
   - Ou escrever manualmente e usar Kiro apenas para revisar?

4. **Limitações:** O que aconteceria se o prompt fosse vago? (ex: "cria docker compose")

---

## Critérios de Participação

| Critério | Peso |
|----------|------|
| Participou ativamente da discussão em grupo | 30% |
| Identificou corretamente os problemas do Rafael | 20% |
| Relacionou recursos do Docker Compose com os problemas | 25% |
| Contribuiu com observações sobre a demonstração do Kiro | 25% |

---

## Para Anotar

Registre suas conclusões da discussão — elas serão úteis durante os laboratórios:

- [ ] Quais são os elementos obrigatórios de um `docker-compose.yml` para o cenário da TechNova?
- [ ] Qual é o fluxo ideal ao usar IA para gerar configurações?
- [ ] Quais pontos de validação são indispensáveis antes de aceitar output de IA?

---

## Entrega

### Onde entregar

No fork do repositório da disciplina, na pasta de entrega da aula:

```
entregas/aula-02/SEU-RA/trabalho-em-aula.md
```

### O que entregar

Um arquivo `trabalho-em-aula.md` com as respostas das atividades realizadas em sala:

```markdown
# Trabalho em Aula — Aula 02: Docker Compose e IA como Copiloto

**Aluno:** [Seu nome completo]  
**RA:** [Seu RA]  
**Data:** [Data da aula]

## Parte 1 — Análise do Problema Multi-Container

### Problemas do Rafael (com classificação)

| # | Problema | Classificação |
|---|---|---|
| 1 | | 🔴/🟡/🟢 |
| 2 | | 🔴/🟡/🟢 |
| 3 | | 🔴/🟡/🟢 |
| 4 | | 🔴/🟡/🟢 |
| 5 | | 🔴/🟡/🟢 |

### Design da Solução

| Problema do Rafael | Recurso do Docker Compose que resolve |
|---|---|
| | |
| | |
| | |
| | |
| | |

## Parte 2 — Observações sobre a Demonstração do Kiro

### O que o Kiro gerou corretamente?
- ...

### O que precisou de ajuste?
- ...

### O que a IA não fez mas deveria?
- ...

### Discussão — respostas

1. **Velocidade vs Qualidade:** ...
2. **Quando confiar:** ...
3. **Cenário real (workflow ideal):** ...
4. **Limitações:** ...
```

### Como entregar

- O arquivo pode ser adicionado no **mesmo PR** do TF ou em PR separado
- A entrega é **individual** — mesmo que a atividade tenha sido em grupo
- Entregas parciais (apenas algumas aulas) **não garantem o ponto**

---

*Após esta discussão, vamos para o Laboratório Parte 1 — onde vocês construirão o docker-compose.yml completo com as próprias mãos.*
