# Trabalho em Aula — Aula 01: Discussão Guiada
**Aluno:** Emilly Santos 
**Data:** 12/09/2026  

## Parte 1 — O Caos do Código

### 1. Problemas identificados (mínimo 4)
- **Sobrescrita e Perda de Código:** Alterações de outros desenvolvedores foram sobrescritas devido ao uso de uma versão desatualizada da base de código.
- **Falta de Rastreabilidade e Autoria:** Impossibilidade de identificar quem fez determinada alteração, quando foi feita e por qual motivo.
- **Falta de Padronização de Versões:** Nomenclatura manual e confusa de arquivos (ex: `USAR_ESSE_AQUI.zip`, `api_v2_final_corrigido_REAL.zip`), gerando incerteza sobre qual é o código em produção.
- **Ausência de Histórico de Mudanças:** Impossibilidade de realizar rollback seguro para um estado anterior funcional em caso de erro.

### 2. Impacto financeiro/operacional
- **Prejuízo Financeiro:** Horas de trabalho desperdiçadas refazendo código perdido e resolvendo incidentes em produção.
- **Atraso na Entrega de Features:** Redução da produtividade da equipe e perda de prazos combinados com clientes/investidores.
- **Danos à Reputação:** Risco elevado de disponibilizar versões instáveis ou incompletas para os clientes finais.

### 3. Como o Git resolve

| Problema Identificado | Como o Git Resolve |
|---|---|
| Sobrescrita acidental de código | Controle de versão distribuído que exige mesclagem (*merge*) e detecta conflitos antes da alteração ser integrada. |
| Nomes de pastas/ZIPs confusos | Histórico de *commits* único com identificadores (*hashes* SHA-1), centralizado num histórico linear ou por branches. |
| Falta de histórico e autoria | Registro exato do autor, data e mensagem descritiva de cada alteração feita no sistema. |
| Impossibilidade de voltar atrás em erros | Comandos de *revert* e *checkout* para restaurar qualquer ponto histórico funcional do projeto em segundos. |

### 4. Regras ao adotar Git
- **Branch Strategy:** Ninguém faz *commit* direto na branch `main`. Toda alteração deve ser feita em *feature branches*.
- **Code Review & Pull Requests:** Todo código deve passar por revisão (*Pull Request*) antes de ser integrado à branch principal.
- **Commits Atômicos e Claros:** Fazer *commits* pequenos, frequentes e com mensagens descritivas seguindo padrões (ex: Conventional Commits).
- **Uso do .gitignore:** Nunca versionar arquivos temporários, builds locais ou credenciais sensíveis.

---

## Parte 2 — "Funciona na Minha Máquina"

### 5. Causa Raiz (3 categorias)
- **Diferenças de Sistema Operacional e Arquitetura:** Incompatibilidade entre macOS, Linux (Ubuntu) e Windows na gestão de sistema de arquivos e bibliotecas nativas.
- **Divergência de Versões de Run-time/Linguagem:** Uso de versões distintas do Node.js (20.11, 20.9 e 18.12) entre as máquinas dos desenvolvedores e o ambiente de staging.
- **Dependências de Sistema e Nativas ausentes:** Dependências como `bcrypt` falhando por falta de bibliotecas nativas (`libssl`) específicas no sistema operacional hospedeiro.

### 6. Requisitos da solução
- **Isolamento:** A aplicação deve rodar dentro de um ambiente isolado, sem interferir ou depender dos pacotes globais do SO hospedeiro.
- **Reprodutibilidade:** O ambiente deve ser construído exatamente da mesma forma a partir de um script/declarativo (ex: `Dockerfile`), em qualquer máquina.
- **Portabilidade:** Capacidade de rodar o mesmo container em macOS, Windows, Linux ou ambientes de nuvem sem alterar o código.
- **Leveza:** Compartilhamento do kernel do sistema hospedeiro para consumo otimizado de RAM e CPU em comparação com máquinas virtuais.

### 7. Container vs. VM

| Aspecto | VM | Container |
|---|---|---|
| Tempo de inicialização | Minutos | Segundos |
| Uso de disco | Gigabytes (requer SO completo) | Megabytes (apenas a app e dependências) |
| Consumo de memória | Alto (memória alocada fixa por VM) | Baixo (compartilha o kernel do hospedeiro) |
| Facilidade de versionamento | Difícil (requer imagens completas/VAGRANT) | Fácil (via `Dockerfile` versionado no Git) |
| Densidade no servidor | Baixa (poucas VMs por host) | Alta (dezenas a centenas de containers por host) |

### 8. Git + Docker juntos
O Git garante que toda a equipe trabalhe exatamente no mesmo código-fonte, enquanto o Docker garante que esse código seja executado dentro de um ambiente idêntico (mesmo SO base, versão do Node.js e dependências nativas). Juntos, eliminam o problema do "funciona na minha máquina" e garantem rastreabilidade do código e do ambiente.

---

## Parte 3 — Proposta para o CTO

Propomos implementar **Git** e **Docker** como padrão na TechNova para eliminar a perda de código e a inconsistência de ambientes. O Git trará histórico unificado e colaboração segura através de *Pull Requests*, enquanto o Docker padronizará o ambiente de execução da API da máquina local ao servidor de staging. Com isso, a equipe aumentará a velocidade de entrega, evitará refazer trabalho e garantirá deploys 100% previsíveis.
