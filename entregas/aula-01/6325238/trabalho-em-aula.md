# Trabalho em Aula — Aula 01: Discussão Guiada

**Aluno:** Yuri Batista Sanches
**RA:** 6325238  
**Data:** 14/08/2026

## Parte 1 — O Caos do Código

### 1. Problemas identificados (mínimo 4)
Não existe uma fonte única de verdade — ninguém sabe qual arquivo é realmente a versão mais atual.

Perda de trabalho — alterações feitas por outros desenvolvedores podem ser sobrescritas.

Falta de histórico — não é possível saber quem alterou o código, quando alterou ou o que foi modificado.

Dificuldade para voltar atrás — caso uma alteração cause um erro, não existe uma maneira simples de recuperar a versão anterior.

### 2. Impacto financeiro/operacional

Financeiramente:

A empresa precisa pagar novamente pelo tempo necessário para refazer o trabalho.
Pode haver atraso na entrega de funcionalidades ou correções.
Um problema em um sistema de pagamentos pode gerar perda de receita ou clientes.
Desenvolvedores podem precisar trabalhar horas extras para recuperar o atraso.

Operacionalmente:

A equipe perde produtividade.
Juliana precisa refazer alterações que já estavam prontas.
Marcos pode precisar interromper outras tarefas para ajudar na recuperação.
O cronograma do projeto pode atrasar.

### 3. Como o Git resolve

| Problema identificado                                       | Como o Git resolve                                                                                   |
| ----------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| Não saber qual é a versão correta                           | O repositório Git possui uma fonte central de código, normalmente a `main`, com versões organizadas. |
| Perda de alterações                                         | Cada alteração pode ser registrada em um **commit**, permitindo recuperar o trabalho anterior.       |
| Não saber quem alterou o código                             | Os commits registram o autor, data e alterações realizadas.                                          |
| Não conseguir voltar para uma versão anterior               | O Git mantém o histórico e permite retornar a commits anteriores.                                    |
| Desenvolvedores sobrescrevendo o trabalho uns dos outros    | Cada desenvolvedor pode trabalhar em uma **branch** própria e depois integrar as alterações.         |
| Dificuldade para trabalhar simultaneamente                  | Branches e ferramentas como `merge` ou Pull Requests permitem combinar trabalhos diferentes.         |
| Arquivos com nomes confusos como `final_corrigido_REAL.zip` | O histórico do Git identifica claramente versões por commits, branches e tags.                       |
| Erros chegando diretamente ao código principal              | A equipe pode exigir Pull Requests e revisão de código antes do `merge` na `main`.                   |

### 4. Regras ao adotar Git
A equipe poderia estabelecer algumas regras básicas:

main deve sempre conter código estável.
Cada nova tarefa deve utilizar uma branch própria.
Nunca sobrescrever o trabalho de outro desenvolvedor.
Utilizar Pull Requests para integrar branches.
Fazer code review antes de integrar alterações na main.


## Parte 2 — "Funciona na Minha Máquina"

### 5. Causa Raiz (3 categorias)
- ...As 3 principais categorias são:

Diferenças de dependências
A biblioteca date-fns não estava instalada ou declarada corretamente.
Versões diferentes de bibliotecas podem apresentar comportamentos diferentes.
Exemplo: date-fns, bcrypt.

Diferenças de runtime/linguagem
Juliana usa Node 20.11, Rafael usa Node 18.12 e o staging usa Node 18.17.
APIs e comportamentos podem mudar entre versões do Node.js.

Diferenças de sistema operacional e bibliotecas do sistema
macOS, Ubuntu e Windows possuem ambientes diferentes.
O staging apresentou incompatibilidade de libssl com bcrypt.
Bibliotecas nativas podem depender do sistema operacional e de bibliotecas instaladas no sistema.

### 6. Requisitos da solução
Uma solução ideal deveria garantir:

Isolamento: cada aplicação deve possuir seu próprio ambiente, sem depender das configurações e bibliotecas instaladas na máquina do desenvolvedor.
Reprodutibilidade: o mesmo projeto deve gerar o mesmo ambiente e comportamento independentemente de quem o execute.
Portabilidade: o ambiente deve funcionar em diferentes máquinas e sistemas, como Windows, Linux e macOS.
Leveza: a solução deve consumir menos recursos e iniciar mais rapidamente que uma máquina virtual completa.

### 7. Container vs. VM

| Aspecto                         | VM                                                          | Container                                                        |
| ------------------------------- | ----------------------------------------------------------- | ---------------------------------------------------------------- |
| **Tempo de inicialização**      | Mais lento, pois inicia um sistema operacional completo     | Muito rápido, pois compartilha o kernel do sistema               |
| **Uso de disco**                | Maior, pois cada VM possui seu próprio SO                   | Menor, pois compartilha componentes do sistema e utiliza imagens |
| **Consumo de memória**          | Maior                                                       | Menor                                                            |
| **Facilidade de versionamento** | Mais complexa, normalmente envolve imagens completas de VMs | Mais simples, através de `Dockerfile`, imagens e tags            |
| **Densidade no servidor**       | Menor quantidade de ambientes por servidor                  | Maior quantidade de containers no mesmo servidor                 |


### 8. Git + Docker juntos

Git e Docker resolvem problemas diferentes, mas trabalham muito bem juntos:

Git: controla o código e seu histórico.
Docker: controla e padroniza o ambiente onde o código será executado.

Fluxo para um novo desenvolvedor
O desenvolvedor instala Git e Docker na máquina.
Faz o clone do repositório da TechNova.
Cria uma branch para sua tarefa.
O projeto já possui um Dockerfile com a definição do ambiente da API.
O desenvolvedor executa o projeto utilizando Docker.
O Docker cria o container com a versão correta do Node.js e todas as dependências necessárias.
A API roda dentro do mesmo ambiente padronizado utilizado pelos demais desenvolvedores.
O desenvolvedor faz suas alterações.
Registra as alterações com commits no Git.
Envia a branch para o repositório remoto.
Abre um Pull Request.
Após a revisão, as alterações são integradas à main.
O mesmo Dockerfile pode ser utilizado no staging e posteriormente em produção.
...

## Parte 3 — Proposta para o CTO

Vamos implementar Git/GitHub para controlar as versões do código e evitar perda de alterações entre os desenvolvedores.
Também vamos utilizar Docker para padronizar os ambientes e evitar problemas de dependências, versões e sistemas operacionais diferentes.
Com essas ferramentas, esperamos melhorar a organização da equipe, reduzir erros e facilitar o desenvolvimento e a entrega da aplicação.
