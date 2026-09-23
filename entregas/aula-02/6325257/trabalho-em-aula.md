# Trabalho em Aula — Aula 02: Docker Compose e IA como Copiloto

**Aluno:** [Luiza Carneiro Rolfsen]  
**RA:** [6325257]  
**Data:** [22/09/2026]

## Parte 1 — Análise do Problema Multi-Container

### Problemas do Rafael (com classificação)

| # | Problema | Classificação |
|---|---|---|
| 1 | 4 comandos complexos | 🟡 Moderado |
| 2 | Ninguém lembra a ordem de inicialização | 🔴 Crítico |
| 3 | Senhas espalhadas e variadas | 🔴 Crítico |
| 4 | Dados se perdem ao reiniciar | 🔴 Crítico |
| 5 | Novos devs sofrem para configurar | 🟡 Moderado |

### Design da Solução

| Problema do Rafael | Recurso do Docker Compose que resolve |
|---|---|
| 4 comandos complexos | Comando único (`docker compose up`) |
| Ninguém lembra a ordem | Declaração `depends_on` (Garante a ordem de subida dos serviços) |
| Senhas espalhadas | Uso de arquivos `.env` para gestão segura de variáveis de ambiente |
| Dados se perdem | Uso de Volumes nomeados (`volumes:`) para persistência de dados |
| Novos devs sofrem | Arquivo YAML versionado (Infraestrutura como Código) |

## Parte 2 — Observações sobre a Demonstração do Kiro

### O que o Kiro gerou corretamente?
- A estrutura base do YAML (versão, serviços).
- A declaração dos serviços essenciais (API e Banco de dados).
- O mapeamento correto de portas (`ports`) e volumes (`volumes`).

### O que precisou de ajuste?
- Inserção de senhas hardcoded (direto no arquivo) em vez de usar variáveis de ambiente seguras.
- Versões das imagens (tags) muito abertas, como `latest`.

### O que a IA não fez mas deveria?
- Não separou as credenciais em um arquivo `.env`.
- Não incluiu *Healthchecks* para garantir que o banco estivesse realmente aceitando conexões antes da API tentar conectar.
- Faltaram configurações de *restart policies* (ex: `restart: always`).

### Discussão — Respostas

1. **Velocidade vs Qualidade:** Precisamos passar o contexto mais completo possível no prompt para que a IA não deixe nada para trás.
2. **Quando confiar:** Fixar uma versão específica (ex: usar `postgres:15` em vez de `latest`) é o ideal para não dar conflito entre as versões de cada máquina, evitando o famoso problema do "não funciona na minha máquina".
3. **Cenário real (workflow ideal):** A IA pode gerar tudo do zero se tiver o contexto completo no prompt, porém a estratégia de fazer o rascunho primeiro e usar a IA apenas para auxiliar e revisar também funciona muito bem.
4. **Limitações:** Se o prompt for vago, a IA criará o Docker na versão mais simples possível, o que trará o retrabalho de ter que ajustar manualmente até o código se adequar à necessidade real do projeto.

...
