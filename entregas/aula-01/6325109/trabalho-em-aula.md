Trabalho em Aula — Discussão Guiada
Parte 1 — O Caos do Código (Sem Controle de Versão)
1. Diagnóstico

Os principais problemas identificados são:

Não existe controle de versão: não é possível saber qual arquivo é realmente o mais atualizado.
Risco de sobrescrever alterações: uma pessoa pode substituir o trabalho de outra, como aconteceu com Marcos e Juliana.
Não existe histórico de alterações: não sabemos quem alterou o código, quando alterou ou o que foi modificado.
Perda de trabalho: os três dias de trabalho da Juliana foram perdidos.
Dificuldade para trabalhar em equipe: várias pessoas podem criar versões diferentes do mesmo sistema.
Dificuldade para recuperar versões anteriores: não existe uma forma organizada de voltar para uma versão que estava funcionando.
2. Consequências

Perder três dias de trabalho de uma desenvolvedora sênior gera impacto financeiro e operacional para a empresa. Além do custo das horas trabalhadas, a equipe precisa gastar mais tempo refazendo o desenvolvimento perdido. Isso pode atrasar entregas, aumentar os custos do projeto, comprometer prazos e gerar novos erros durante o retrabalho.

3. Solução Git
Problema Identificado	Como o Git Resolve
Não saber qual versão é a correta	O Git mantém um repositório com histórico e uma branch principal, normalmente main.
Alterações sendo sobrescritas	Cada desenvolvedor pode trabalhar em uma branch própria e depois integrar as alterações.
Não saber quem fez uma alteração	Cada commit registra o autor, a data e as alterações realizadas.
Perda de trabalho	O histórico do Git permite recuperar versões anteriores.
Várias pessoas trabalhando ao mesmo tempo	Branches permitem que diferentes desenvolvedores trabalhem em paralelo.
Erros em uma alteração	É possível comparar, corrigir ou reverter alterações.
Dificuldade para identificar mudanças	O Git permite comparar versões utilizando ferramentas como git diff.
4. Prevenção

A equipe deveria estabelecer algumas regras:

Utilizar um repositório Git centralizado.
Não fazer alterações diretamente na branch main.
Criar uma branch para cada funcionalidade ou correção.
Utilizar um padrão de nomes para branches, como feature/nova-funcionalidade e fix/correcao-erro.
Fazer commits pequenos e objetivos.
Utilizar mensagens de commit claras.
Fazer pull antes de começar a trabalhar.
Utilizar Pull Requests para revisão de código.
Manter a branch main sempre estável.
Nunca armazenar senhas, chaves ou arquivos .env no repositório.
Parte 2 — "Funciona na Minha Máquina"
5. Causa Raiz

As três principais categorias de diferenças entre os ambientes são:

1. Dependências:
O Rafael recebeu o erro Cannot find module 'date-fns', indicando diferença ou ausência de dependências.

2. Versões do ambiente/runtime:
Os desenvolvedores e o servidor utilizam versões diferentes do Node.js:

Juliana: Node 20.11
Rafael: Node 18.12
Marcos: Node 20.9
Staging: Node 18.17

Essas diferenças podem causar comportamentos diferentes na aplicação.

3. Sistema operacional e bibliotecas do sistema:
Os ambientes utilizam macOS, Ubuntu e Windows. Além disso, o servidor apresentou incompatibilidade entre libssl e bcrypt.

Portanto, a causa raiz pode ser resumida como:

Diferenças de dependências, versões do runtime e sistema operacional/bibliotecas do sistema.

6. Requisitos da Solução
Isolamento: cada aplicação deve possuir seu próprio ambiente e suas dependências, sem depender da configuração da máquina do desenvolvedor.
Reprodutibilidade: o mesmo código deve conseguir gerar o mesmo ambiente e comportamento em diferentes máquinas.
Portabilidade: a aplicação deve poder ser executada em diferentes computadores e servidores.
Leveza: o ambiente deve consumir poucos recursos e iniciar rapidamente.

A tecnologia que atende bem a esses requisitos é o Docker.

7. Container vs. VM
Aspecto	VM	Container
Tempo de inicialização	Mais lento	Muito rápido
Uso de disco	Maior	Menor
Consumo de memória	Maior	Menor
Facilidade de versionamento	Mais complexa	Mais simples
Densidade no servidor	Menor	Maior

VM: possui um sistema operacional completo, oferecendo bastante isolamento, porém consome mais recursos.

Container: compartilha o kernel do sistema operacional e contém a aplicação e suas dependências, sendo mais leve, rápido e fácil de reproduzir.

Para o problema da TechNova, containers seriam mais adequados para padronizar o ambiente dos desenvolvedores.

8. A Conexão — Git + Docker

O novo desenvolvedor seguiria este fluxo:

Instalar Git e Docker.
Clonar o repositório do projeto utilizando Git.
Entrar na pasta do projeto.
Utilizar o Dockerfile e o docker-compose.yml fornecidos pelo projeto.
Executar docker compose up.
O Docker criará os containers com as versões e dependências definidas.
A API e os demais serviços necessários serão executados no ambiente padronizado.
O desenvolvedor poderá trabalhar no código e utilizar Git para registrar e compartilhar suas alterações.
O papel de cada ferramenta

Git: controla o código, histórico, versões e colaboração entre os desenvolvedores.

Docker: padroniza o ambiente, as dependências e a execução da aplicação.

Dessa forma:

Git resolve o problema do código e Docker resolve o problema do ambiente.

Parte 3 — Síntese
Proposta para o CTO

Carlos, propomos implementar Git para controlar as versões do código e Docker para padronizar os ambientes de desenvolvimento e execução. Com Git, a equipe poderá trabalhar em paralelo, manter o histórico das alterações e recuperar versões anteriores. Com Docker, teremos ambientes isolados, reproduzíveis e portáveis. Com isso, a TechNova poderá trabalhar de forma mais segura e colaborativa, reduzindo a perda de código e o problema de "funciona na minha máquina".