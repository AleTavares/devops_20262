# Trabalho em Aula - Aula 01: Fundamentos de Git e Docker

**Aluno:** Gabriel Carneiro da Silva  
**RA:** 6325300  
**Data:** 17/08/2026

## Parte 1 - O Caos do Codigo

### 1. Diagnostico

Problemas que podem ocorrer sem controle de versao:

- Ninguem sabe qual arquivo e a versao correta do sistema.
- Alteracoes de uma pessoa podem sobrescrever o trabalho de outra.
- Nao existe historico confiavel para descobrir quem mudou algo e quando.
- Fica dificil voltar para uma versao anterior quando surge um erro.
- Backups manuais podem estar desatualizados ou com nomes confusos.

### 2. Consequencias

Perder 3 dias de trabalho de uma desenvolvedora senior causa atraso no projeto, retrabalho, custo financeiro e perda de confianca no processo. Tambem pode atrasar entregas para clientes e aumentar o risco de colocar uma versao errada em producao.

### 3. Solucao Git

| Problema identificado | Como o Git resolve |
|---|---|
| Nao saber qual versao e a correta | A branch `main` passa a ser a fonte principal e confiavel do projeto |
| Sobrescrever trabalho de outra pessoa | Cada mudanca vira commit e pode ser integrada por branch e merge |
| Nao saber quem alterou algo | O historico registra autor, data e mensagem de cada commit |
| Dificuldade para voltar versoes | O Git permite consultar commits anteriores e recuperar arquivos |
| Copias zip com nomes confusos | O repositorio substitui arquivos soltos por historico organizado |

### 4. Regras para a equipe

- Usar `main` apenas para codigo estavel.
- Criar branches para novas funcionalidades, como `feature/nome-da-funcionalidade`.
- Fazer commits pequenos e descritivos usando Conventional Commits.
- Nunca versionar `.env`, `node_modules/`, chaves privadas ou arquivos temporarios.
- Revisar mudancas antes de integrar na branch principal.

## Parte 2 - Funciona na Minha Maquina

### 5. Causa raiz

As falhas vieram de tres categorias principais:

- Versoes diferentes do runtime, como Node.js 18 e Node.js 20.
- Dependencias ausentes ou instaladas de forma diferente.
- Diferencas de sistema operacional e bibliotecas nativas.

### 6. Requisitos da solucao

- Isolamento: a aplicacao roda separada do sistema operacional da maquina.
- Reprodutibilidade: o mesmo ambiente pode ser reconstruido sempre.
- Portabilidade: funciona no computador do dev, no servidor e no CI/CD.
- Leveza: consome menos recursos que uma maquina virtual completa.

### 7. Container vs VM

| Aspecto | VM | Container |
|---|---|---|
| Tempo de inicializacao | Mais lento, pois inicia um SO completo | Mais rapido, pois inicia apenas processos isolados |
| Uso de disco | Alto, normalmente em GB | Menor, normalmente em MB |
| Consumo de memoria | Maior | Menor |
| Facilidade de versionamento | Mais dificil versionar uma VM inteira | Dockerfile pode ser versionado no Git |
| Densidade no servidor | Menos VMs por servidor | Mais containers por servidor |

### 8. Conexao Git + Docker

Git organiza o historico do codigo e Docker padroniza o ambiente de execucao. Um novo desenvolvedor pode clonar o repositorio, construir a imagem com `docker build` e rodar a aplicacao com `docker run`, obtendo o mesmo resultado independentemente da maquina.

## Parte 3 - Proposta para o CTO

Carlos, propomos implementar Git para resolver o caos de versoes do codigo e Docker para resolver as diferencas entre ambientes. Com isso, a equipe da TechNova podera trabalhar com historico confiavel, branches, commits rastreaveis e containers reproduziveis. O resultado esperado e reduzir retrabalho, evitar perda de codigo e garantir que a API rode de forma igual em desenvolvimento, testes e producao.
