# Trabalho em Aula — Aula 01: Discussão Guiada

## Parte 1 — O Caos do Código

### 1. Problemas identificados (mínimo 4)

- Falta de controle sobre as versões do código.
- Não existe uma forma clara de identificar qual arquivo é a versão mais atual e correta.
- Alterações de diferentes desenvolvedores podem ser sobrescritas.
- Não existe histórico para saber quem alterou o código, quando e o que foi alterado.
- É difícil recuperar uma versão anterior quando ocorre algum problema.
- O trabalho de outros desenvolvedores pode ser perdido acidentalmente.

### 2. Impacto financeiro/operacional

A perda de três dias de trabalho de uma desenvolvedora sênior gera prejuízo financeiro porque a empresa precisa pagar novamente pelo tempo necessário para refazer as alterações. Além disso, pode atrasar a entrega de funcionalidades e correções, reduzir a produtividade da equipe e aumentar o risco de novos erros.

Também existe um impacto operacional, pois outros desenvolvedores podem ficar bloqueados ou precisar interromper suas atividades para recuperar o trabalho perdido.

### 3. Como o Git resolve

| Problema Identificado | Como o Git Resolve |
|---|---|
| Não saber qual é a versão correta | O repositório possui um histórico organizado e branches que permitem controlar as versões do projeto. |
| Alterações sendo sobrescritas | Cada alteração é registrada em commits e diferentes branches permitem trabalhar sem sobrescrever o trabalho de outras pessoas. |
| Perda do trabalho de um desenvolvedor | Os commits armazenam as alterações no histórico, permitindo recuperá-las posteriormente. |
| Não saber quem fez determinada alteração | Cada commit registra o autor, a data e as alterações realizadas. |
| Dificuldade para recuperar uma versão anterior | O histórico do Git permite consultar e restaurar versões anteriores do código. |
| Conflitos entre alterações | O Git identifica conflitos durante merges, permitindo que a equipe resolva as diferenças antes de juntar as alterações. |

### 4. Regras ao adotar Git

- Utilizar uma branch principal como referência do código estável.
- Criar uma branch específica para cada tarefa, funcionalidade ou correção.
- Utilizar nomes padronizados para as branches.
- Fazer commits pequenos e com mensagens claras e descritivas.
- Não trabalhar diretamente na branch principal.
- Fazer push regularmente para o repositório remoto.
- Utilizar Pull Requests para revisar e integrar alterações.
- Realizar code review antes de juntar alterações à branch principal.
- Manter o repositório atualizado antes de começar novos trabalhos.
- Não armazenar arquivos desnecessários ou versões compactadas do projeto no repositório.

## Parte 2 — "Funciona na Minha Máquina"

### 5. Causa Raiz (3 categorias)

- **Dependências:** versões ou pacotes necessários não estavam disponíveis ou estavam diferentes entre os ambientes, como o `date-fns` e o `bcrypt`.
- **Runtime/linguagem:** os ambientes utilizavam versões diferentes do Node.js, como Node 18 e Node 20, o que pode causar comportamentos diferentes.
- **Sistema operacional e bibliotecas do sistema:** macOS, Ubuntu e Windows possuem diferenças de bibliotecas e configurações. No staging, por exemplo, ocorreu incompatibilidade da `libssl` com o `bcrypt`.

### 6. Requisitos da solução

- **Isolamento:** cada aplicação deve possuir suas próprias dependências e configurações, sem depender diretamente do ambiente do computador.
- **Reprodutibilidade:** o mesmo código deve gerar um ambiente equivalente sempre que for executado.
- **Portabilidade:** o ambiente deve poder ser executado em diferentes máquinas e sistemas com o mínimo de alterações.
- **Leveza:** a solução deve consumir menos recursos e iniciar mais rapidamente do que uma máquina virtual completa.

### 7. Container vs. VM

| Aspecto | VM | Container |
|---|---|---|
| Tempo de inicialização | Mais lento, pois inicializa um sistema operacional completo. | Mais rápido, pois compartilha o kernel do sistema hospedeiro. |
| Uso de disco | Maior, pois cada VM possui seu próprio sistema operacional. | Menor, pois as imagens são mais enxutas e podem compartilhar camadas. |
| Consumo de memória | Maior. | Geralmente menor. |
| Facilidade de versionamento | Pode ser feito por snapshots e imagens, mas tende a ser mais pesado. | Imagens podem ser versionadas e distribuídas de forma prática. |
| Densidade no servidor | Menor quantidade de ambientes por servidor devido ao maior consumo de recursos. | Maior quantidade de containers no mesmo servidor. |

### 8. Git + Docker juntos

O novo desenvolvedor começaria clonando o repositório Git e entrando na branch correspondente à atividade. Em seguida, utilizaria o Docker para construir ou baixar a imagem da aplicação, contendo a versão definida do Node.js, dependências e demais configurações necessárias.

Depois, executaria a API dentro do container, garantindo que o ambiente utilizado seja semelhante ao dos demais desenvolvedores e ao staging.

O fluxo seria:

1. Clonar o repositório.
2. Acessar a branch da atividade.
3. Construir a imagem Docker.
4. Iniciar os containers.
5. Executar e testar a API.
6. Realizar as alterações.
7. Criar commits.
8. Enviar a branch para o repositório remoto.
9. Abrir um Pull Request para revisão.

Dessa forma, o Git controla as versões do código e o Docker padroniza o ambiente de execução, reduzindo problemas de compatibilidade e o cenário de "funciona na minha máquina".

## Parte 3 — Proposta para o CTO

Propomos implementar **Git** para controlar as versões do código e **Docker** para padronizar os ambientes de desenvolvimento, testes e staging. Com isso, a equipe da TechNova poderá trabalhar de forma colaborativa, recuperar alterações quando necessário e executar a aplicação em ambientes consistentes. Dessa forma, reduziremos a perda de código, os conflitos entre versões e os problemas de incompatibilidade entre máquinas.