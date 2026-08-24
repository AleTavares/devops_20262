# Trabalho em Aula — Aula 01: Discussão Guiada

**Aluno:** Matheus Maciel de Paula
**RA:** 6325065
**Data:** 13/08/2026

## Parte 1 — O Caos do Código

### 1. Problemas identificados

* Não existe uma fonte confiável para saber qual é a versão mais recente do sistema.
* Alterações podem ser sobrescritas, causando a perda do trabalho de outros desenvolvedores.
* Não existe um histórico organizado que mostre quem alterou cada arquivo e quando isso aconteceu.
* A equipe não consegue restaurar facilmente uma versão anterior quando ocorre um erro.
* Dois desenvolvedores podem modificar o mesmo código sem perceber, gerando conflitos e retrabalho.
* A grande quantidade de arquivos compactados ocupa espaço e dificulta a organização do projeto.

### 2. Impacto financeiro e operacional

A perda de três dias de trabalho representa desperdício do salário e do tempo de uma desenvolvedora sênior. Além desse custo direto, a equipe precisará interromper outras tarefas para refazer e revisar o código perdido. Isso pode atrasar a correção do módulo de pagamentos, gerar horas extras e prejudicar clientes. A situação também diminui a produtividade e a confiança da equipe no processo de desenvolvimento.

### 3. Como o Git resolve

| Problema identificado                         | Como o Git resolve                                                                          |
| --------------------------------------------- | ------------------------------------------------------------------------------------------- |
| Não saber qual é a versão correta             | A branch `main` funciona como fonte principal e confiável do projeto.                       |
| Alterações sobrescritas e trabalho perdido    | Cada desenvolvedor trabalha em sua própria branch e as alterações são integradas por merge. |
| Falta de histórico das modificações           | Os commits registram as alterações, o autor, a data e uma mensagem explicativa.             |
| Dificuldade para recuperar versões anteriores | O Git permite consultar o histórico e restaurar arquivos ou commits anteriores.             |
| Alterações simultâneas no mesmo código        | O Git identifica conflitos de merge para que sejam resolvidos de maneira controlada.        |
| Falta de revisão antes de publicar            | Pull Requests permitem revisar, discutir e testar o código antes do merge.                  |

### 4. Regras ao adotar Git

* Manter a branch `main` protegida e estável.
* Não fazer alterações diretamente na `main`.
* Criar uma branch para cada funcionalidade ou correção.
* Utilizar nomes descritivos, como `feature/listagem-pedidos` e `fix/erro-pagamento`.
* Fazer commits pequenos e relacionados a uma única mudança.
* Utilizar mensagens claras seguindo Conventional Commits, como `feat:`, `fix:` e `docs:`.
* Atualizar a branch local antes de começar a trabalhar.
* Abrir Pull Requests e exigir revisão antes do merge.
* Testar o código antes de integrá-lo à `main`.
* Utilizar `.gitignore` para impedir o versionamento de dependências, logs e informações sensíveis.

## Parte 2 — “Funciona na Minha Máquina”

### 5. Causa raiz

As falhas foram provocadas por três categorias principais de diferenças:

1. **Versões do ambiente de execução:** os computadores utilizavam versões diferentes do Node.js, como Node 18 e Node 20.
2. **Dependências da aplicação:** o pacote `date-fns` estava ausente ou não foi instalado de maneira padronizada.
3. **Sistema operacional e bibliotecas nativas:** macOS, Windows e Ubuntu possuem diferenças, incluindo versões de bibliotecas como `libssl`, que afetaram o funcionamento do `bcrypt`.

### 6. Requisitos da solução

* **Isolamento:** cada aplicação deve executar com suas próprias dependências, sem interferir em outros projetos ou no computador do desenvolvedor.
* **Reprodutibilidade:** o mesmo código e as mesmas configurações devem produzir um ambiente igual em qualquer máquina.
* **Portabilidade:** a aplicação deve executar de maneira consistente no computador dos desenvolvedores, nos testes e no servidor.
* **Leveza:** o ambiente deve consumir poucos recursos e iniciar rapidamente.

### 7. Container vs. VM

| Aspecto                     | VM                                                | Container                                              |
| --------------------------- | ------------------------------------------------- | ------------------------------------------------------ |
| Tempo de inicialização      | Geralmente leva minutos                           | Geralmente leva segundos                               |
| Uso de disco                | Alto, pois inclui um sistema operacional completo | Menor, pois compartilha o kernel do sistema hospedeiro |
| Consumo de memória          | Alto                                              | Baixo em comparação com uma VM                         |
| Facilidade de versionamento | Imagens grandes e difíceis de manter              | O Dockerfile pode ser versionado junto com o código    |
| Densidade no servidor       | Menor quantidade de VMs por servidor              | Maior quantidade de containers por servidor            |

As máquinas virtuais oferecem um isolamento mais completo porque cada VM possui seu próprio sistema operacional. Porém, são mais pesadas e lentas. Containers são mais adequados para o desenvolvimento e a implantação dessa API porque iniciam rapidamente, utilizam menos recursos e podem ser reproduzidos por meio de um Dockerfile.

### 8. Git e Docker juntos

O Git armazenaria o código, o histórico, as branches e o Dockerfile do projeto. Um novo desenvolvedor começaria clonando o repositório com `git clone` e acessando a versão principal na branch `main`. Em seguida, utilizaria `docker build` para construir a imagem com a versão correta do Node.js e todas as dependências necessárias. Depois, executaria a aplicação com `docker run`, obtendo o mesmo ambiente utilizado pelo restante da equipe. Dessa maneira, o Git garante a versão correta do código e o Docker garante a padronização do ambiente.

## Parte 3 — Proposta para o CTO

Propomos implementar Git e Docker no processo de desenvolvimento da TechNova.
O Git será responsável pelo histórico, pela colaboração por branches e pela proteção contra perda de código.
O Docker padronizará as versões, dependências e bibliotecas utilizadas pela aplicação.
Com essas ferramentas, a equipe poderá trabalhar com segurança e executar a API de forma consistente em qualquer ambiente.
