# Trabalho em Aula — Aula 01: Discussão Guiada

**Aluno:** [Luiza Carneiro Rolfsen]
**RA:** [6325257]
**Data:** [21/09/2026]

## Parte 1 — O Caos do Código

### 1. Problemas identificados (mínimo 4)
- **Risco de sobrescrita:** Impossibilidade de trabalho colaborativo simultâneo seguro.
- **Falta de rastreabilidade:** Ausência de histórico detalhado (quem alterou, quando e por qual motivo).
- **Dificuldade de reversão (Rollback):** Impossibilidade de retornar facilmente para uma versão anterior estável em caso de falhas.
- **Falta de uma "fonte da verdade":** Bagunça nos nomes dos arquivos e pastas (ex: `.zip`), gerando confusão sobre qual é a versão oficial de produção.

### 2. Impacto financeiro/operacional
- **Atraso no cronograma:** Efeito cascata nas entregas da equipe, pois os desenvolvedores precisam refazer partes do código que foram perdidas.
- **Prejuízo financeiro:** Desperdício de horas pagas a desenvolvedores seniores por um trabalho que precisará ser refeito.
- **Impacto cultural:** Gera frustração, atritos e queda de confiança no fluxo de trabalho da equipe.

### 3. Como o Git resolve

| Problema Identificado | Como o Git Resolve |
|---|---|
| Risco de sobrescrita em trabalho simultâneo | Permite o uso de branches isoladas para cada tarefa e faz o merge inteligente do código, alertando sobre conflitos. |
| Falta de rastreabilidade | O uso de `commits` registra o autor, a data/hora e uma mensagem descritiva do que foi alterado, criando um histórico auditável. |
| Dificuldade de reversão para versões estáveis | Permite usar comandos focados no ID (hash) de um commit para voltar o projeto rapidamente no tempo para um estado funcional. |
| Ausência de uma versão unificada e oficial | A branch `main` atua como a única fonte da verdade do projeto, eliminando cópias de arquivos. |

### 4. Regras ao adotar Git
- **Padronização:** Uso de *Conventional Commits* nas mensagens de commit.
- **Isolamento de tarefas:** Implementação do uso de branches dedicadas para cada desenvolvedor.
- **Revisão de Código:** Obrigatoriedade de abertura de Pull Request (PR) com aprovação de um desenvolvedor sênior antes de integrar à branch principal.
- **Sincronização:** Manter as branches de trabalho constantemente atualizadas com a branch do projeto principal para otimizar o trabalho e evitar conflitos severos.

## Parte 2 — "Funciona na Minha Máquina"

### 5. Causa Raiz (3 categorias)
- **Sistemas Operacionais (SO):** Diferenças de base e comportamento entre macOS, Ubuntu e Windows.
- **Versão do Runtime:** Incompatibilidades causadas pelas diferentes versões do motor Node.js (18.x vs 20.x).
- **Dependências/Bibliotecas:** Inconsistência nos pacotes do projeto (falta de instalação prévia das libs) e conflito com bibliotecas nativas do sistema (ex: libssl x bcrypt).

### 6. Requisitos da solução
- **Isolamento:** Garantir que a aplicação rode separada do sistema operacional hospedeiro e de outras aplicações.
- **Reprodutibilidade:** Garantir que se a aplicação funciona em uma máquina, execute com as exatas mesmas dependências e versões em qualquer outro ambiente.
- **Portabilidade:** Garantir que o projeto possa ser facilmente movido entre diferentes sistemas operacionais e infraestruturas de nuvem.
- **Leveza:** Consumir menos recursos (memória, CPU e disco) e iniciar mais rápido do que uma Máquina Virtual (VM).

### 7. Container vs. VM

| Aspecto | VM | Container |
|---|---|---|
| Tempo de inicialização | Lento | Rápido |
| Uso de disco | Alto | Baixo |
| Consumo de memória | Alto | Baixo |
| Facilidade de versionamento | Difícil | Fácil |
| Densidade no servidor | Poucas aplicações | Várias aplicações |

### 8. Git + Docker juntos
Um novo desenvolvedor chegando à equipe seguiria um fluxo simples e livre de instalações manuais:
1. Roda o comando `git clone` para trazer o repositório para sua máquina, garantindo acesso à versão unificada e com todo o histórico do projeto.
2. Dentro da pasta, roda o comando `docker compose up -d` (ou similar). O Docker assumirá a responsabilidade de ler as configurações, baixar a versão correta do ambiente (ex: Node.js) e instalar todas as dependências isoladamente.
3. A aplicação subirá perfeitamente sem que o desenvolvedor precise instalar linguagens ou bibliotecas no sistema operacional nativo de sua máquina.

## Parte 3 — Proposta para o CTO

"Carlos, propomos implementar **Git e Docker** para resolver **os problemas de versionamento de código e a falta de padronização dos ambientes**. Com isso, a equipe da TechNova poderá **trabalhar de forma colaborativa, garantindo a execução da aplicação em qualquer lugar,** e nunca mais **terá problemas com código sobrescrito ou aplicações que não rodam nas máquinas dos desenvolvedores**."
