# Trabalho em Aula — Discussão Guiada

## Briefing do CTO da TechNova

> A equipe foi chamada para ajudar a TechNova a resolver dois problemas: perda de código e ambiente diferente em cada máquina.

---

## Parte 1 — O Caos do Código (Sem Controle de Versão)

### Cenário

Leia o trecho abaixo do relatório interno da TechNova:

> Na segunda-feira, o Marcos precisava implementar uma correção urgente no módulo de pagamentos. Ele abriu a pasta compartilhada no servidor e encontrou os seguintes arquivos:
>
> ```
> /servidor/codigo/
> ├── api_v2.zip
> ├── api_v2_final.zip
> ├── api_v2_final_corrigido.zip
> ├── api_v2_final_corrigido_REAL.zip
> ├── api_backup_rafael_sexta.zip
> ├── api_juliana_nova_versao.zip
> └── USAR_ESSE_AQUI.zip
> ```
>
> Marcos escolheu `USAR_ESSE_AQUI.zip`, fez a correção e sobrescreveu o arquivo. No dia seguinte, a Juliana descobriu que as alterações dela dos últimos 3 dias haviam sumido — o arquivo que Marcos usou era de uma semana atrás.

### Discussão em Grupo

Responda em grupo:

**1. Qual problema aconteceu no cenário sem Git?**

**2. O que isso custa para a empresa?**

**3. Como o Git ajudaria a resolver isso?**

**4. Quais regras a equipe deveria seguir ao usar Git?**

---

## Parte 2 — "Funciona na Minha Máquina" (Inconsistência de Ambientes)

### Cenário

Leia o relatório de incidente da Juliana:

> **De:** Juliana Santos, Desenvolvedora Sênior — TechNova  
> **Para:** Equipe de Platform Engineering  
> **Assunto:** URGENTE — API falhando em múltiplos ambientes

> Na terça-feira, terminei a feature de listagem de pedidos com filtro por data. Testei localmente: **funcionou perfeitamente**. Fiz push para o repositório.
>
> O Rafael fez pull e recebeu: `Error: Cannot find module 'date-fns'`
>
> O Marcos conseguiu instalar, mas ao rodar: `TypeError: date.toLocaleString is not a function`
>
> No servidor de staging: incompatibilidade de `libssl` com `bcrypt`.
>
> **Resultado:**
> - Meu laptop (macOS, Node 20.11): ✅ Funciona
> - Rafael (Ubuntu, Node 18.12): ❌ Falha na instalação
> - Marcos (Windows 11, Node 20.9): ❌ Comportamento diferente
> - Servidor staging (Ubuntu 22.04, Node 18.17): ❌ Incompatibilidade de libs

### Discussão em Grupo

**5. Quais tipos de diferenças de ambiente causaram o problema?**

**6. O que uma solução ideal deveria garantir?**
- Isolamento: __________
- Reprodutibilidade: __________
- Portabilidade: __________
- Leveza: __________

**7. Container ou VM?** Complete a tabela:

| Aspecto | VM | Container |
|---|---|---|
| Inicialização | | |
| Uso de disco | | |
| Consumo de memória | | |
| Velocidade | | |

**8. Como Git e Docker juntos resolvem o problema da TechNova?**

---

## Parte 3 — Síntese

### Proposta para o CTO

Com base nas discussões, cada grupo deve redigir uma proposta de **3-5 linhas** para o CTO com:

1. O que vocês implementarão (ferramentas)
2. O problema que cada ferramenta resolve
3. O resultado esperado para a equipe

> **Modelo:**
> "Carlos, propomos implementar Git e Docker para resolver o caos de versionamento e a inconsistência de ambientes. Com isso, a equipe da TechNova poderá colaborar com mais segurança e nunca mais perder trabalho nem depender de uma máquina específica."

---

## Critérios de Avaliação

| Critério | Peso |
|----------|:---:|
| Participação ativa na discussão | 30% |
| Identificação correta dos problemas | 20% |
| Qualidade das soluções propostas | 25% |
| Conexão entre Git e Docker na proposta | 15% |
| Clareza na apresentação oral | 10% |

---

## Formato

- **Duração:** 30 minutos (incluído no Bloco 1 da aula)
- **Grupos:** 3-4 pessoas
- **Entrega:** Não há entrega formal — a avaliação é pela participação e qualidade da discussão

---

*Após a discussão, passaremos para o conteúdo teórico de Git (Bloco 2), seguido do laboratório hands-on.*
