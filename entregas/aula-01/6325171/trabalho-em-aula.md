# Trabalho em Aula — Aula 01: Discussao Guiada

**Aluno:** Nicolas de Jesus Silva  
**RA:** 6325171  
**Data:** 19/11/2026

## Parte 1 — O Caos do Codigo

### 1. Problemas identificados

- Nao existe uma fonte unica e confiavel para identificar a versao mais recente.
- Alteracoes de pessoas diferentes se sobrescrevem sem aviso ou historico.
- Nao e possivel saber quem mudou o arquivo, quando, nem por que.
- Recuperar uma versao anterior depende de encontrar um ZIP correto.
- A equipe nao consegue trabalhar em paralelo com seguranca.

### 2. Impacto financeiro/operacional

A empresa perde horas reconstruindo alteracoes, atrasa correcoes e releases, aumenta o risco de defeitos em producao e nao consegue auditar nem atribuir mudancas. Em um modulo de pagamentos, uma versao antiga pode reintroduzir falhas e causar pedidos incorretos.

### 3. Como o Git resolve

| Problema Identificado | Como o Git Resolve |
|---|---|
| Varios arquivos com nomes de versao ambiguos | Historico de commits e uma referencia clara para cada versao |
| Alteracao de uma pessoa apaga a de outra | Branches isoladas e merge com deteccao de conflitos |
| Nao ha como identificar a origem da mudanca | Commits registram autor, data e mensagem |
| Recuperacao manual de ZIP | `git revert` ou checkout de uma revisao conhecida |
| Release sem identificacao estavel | Tags apontam para commits de release |

### 4. Regras ao adotar Git

- Manter `main` protegida e integrar mudancas por pull request.
- Criar uma branch curta por tarefa e sincroniza-la antes do merge.
- Fazer commits pequenos, coerentes e com mensagens claras.
- Revisar conflitos e executar testes antes de aprovar.
- Nao usar force push em branches compartilhadas.
- Manter segredos e arquivos locais fora do repositorio com `.gitignore`.

## Parte 2 — "Funciona na Minha Maquina"

### 5. Causa raiz

- **Dependencias:** `date-fns` nao estava declarada/instalada de forma reproduzivel; versoes de pacotes podem divergir.
- **Runtime e comportamento:** Node 18 e Node 20 podem ter diferencas, e o codigo usa um valor `date` que nao e um objeto `Date` em todos os ambientes.
- **Sistema operacional e bibliotecas nativas:** `bcrypt` depende de binarios e bibliotecas como OpenSSL, que variam entre macOS, Windows e Ubuntu.

### 6. Requisitos da solucao

- **Isolamento:** separar dependencias da aplicacao do sistema hospedeiro.
- **Reprodutibilidade:** fixar versoes do runtime e dependencias; usar lockfile e imagem identificada por tag/digest.
- **Portabilidade:** usar uma imagem OCI executavel em ambientes compativeis com containers.
- **Leveza:** compartilhar o kernel do host em vez de executar um sistema operacional convidado completo.

### 7. Container vs. VM

| Aspecto | VM | Container |
|---|---|---|
| Tempo de inicializacao | Geralmente dezenas de segundos ou minutos | Geralmente segundos |
| Uso de disco | Imagem de sistema operacional completa | Camadas da aplicacao e dependencias |
| Consumo de memoria | Maior, inclui o sistema convidado | Menor, compartilha o kernel do host |
| Facilidade de versionamento | Snapshot normalmente maior e menos portavel | Imagens versionadas e distribuidas por registry |
| Densidade no servidor | Menos instancias por host | Mais containers por host |

### 8. Git + Docker juntos

O Git registra e revisa a mudanca de codigo; o Docker empacota codigo, runtime e dependencias em uma imagem reproduzivel. O pipeline pode associar cada imagem ao commit que a gerou, testar a mesma imagem em diferentes ambientes e reverter para uma versao identificada sem depender da configuracao de uma maquina.

## Parte 3 — Proposta para o CTO

Carlos, propomos padronizar o Git para registrar mudancas e permitir colaboracao por branches e pull requests, e o Docker para empacotar a API com suas dependencias. O pipeline vai testar e construir uma imagem versionada a partir de cada commit, reduzindo perda de codigo, divergencia entre ambientes e tempo de recuperacao.
