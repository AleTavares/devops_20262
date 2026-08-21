### Discussão em Grupo


**1. Diagnóstico:**

Alguns problemas que podem acontecer:

- Não saber qual é a versão mais atual do código.
- Perder o trabalho de outra pessoa.
- Não saber quem fez determinada alteração.
- Não conseguir voltar facilmente para uma versão anterior.
- Duas pessoas podem alterar o mesmo código e acabar sobrescrevendo o trabalho uma da outra.

________________________________________________________________________________

**2. Consequências:**

Perder três dias de trabalho de uma desenvolvedora sênior gera prejuízo para a empresa porque será necessário refazer esse trabalho. Além disso, pode atrasar outras tarefas e entregas do projeto. Também existe o risco de a equipe perder tempo tentando descobrir o que aconteceu.

________________________________________________________________________________

**3. Solução Git:**

| Problema Identificado               | Como o Git Resolve |

Não saber qual é a versão correta	  |   O Git mantém uma versão principal do projeto e mostra o histórico.
Perder alterações	                  |   Cada alteração fica registrada em commits.
Não saber quem alterou o código  	  |   O Git mostra quem fez cada commit.
Não conseguir voltar para uma versão  |   É possível recuperar ou voltar para versões anteriores.
anterior	                          |
Pessoas sobrescreverem o trabalho     | Cada pessoa pode trabalhar em uma branch diferente e depois juntar as  
umas das outras	                      |    alterações. 

________________________________________________________________________________

**4. Prevenção:**

A equipe poderia criar algumas regras:

- Cada funcionalidade deve ter sua própria branch.
- Fazer commits com mensagens que expliquem o que foi alterado.
- Não alterar diretamente a main.
- Usar Pull Request para revisar as alterações.
- Pelo menos outra pessoa deve revisar alterações importantes.
- Sempre atualizar o código antes de começar a trabalhar.
- Não usar vários arquivos .zip para controlar as versões.

________________________________________________________________________________

## Parte 2 — "Funciona na Minha Máquina" (Inconsistência de Ambientes)

### Discussão em Grupo

**5. Causa Raiz:**

1. Sistema operacional:
Juliana usa macOS, Rafael e o servidor usam Ubuntu e Marcos usa Windows.

2. Versão do Node.js:
Cada computador está usando uma versão diferente do Node.

3. Bibliotecas e dependências:
As máquinas podem ter versões diferentes das bibliotecas ou até bibliotecas que não estão instaladas. O problema do libssl e do bcrypt mostra isso.

________________________________________________________________________________

**6. Requisitos da Solução:**

- Isolamento: cada aplicação deve ter seu próprio ambiente.
- Reprodutibilidade: o ambiente deve poder ser criado novamente da mesma forma.
- Portabilidade: deve funcionar em diferentes computadores e servidores.
- Leveza: deve usar poucos recursos e iniciar rapidamente.

O Docker é uma boa solução para isso porque utiliza containers.


________________________________________________________________________________

**7. Container vs. VM:**

Aspecto                |     VM      |       Container

Tempo de inicialização | Mais lento	 |       Mais rápido
Uso de disco           |   	Maior	 |        Menor
Consumo de memória	   |    Maior	 |        Menor
Facilidade de          |Mais difícil |	    Mais fácil
versionamento	
Densidade no servidor  |	Menor	 |        Maior


________________________________________________________________________________

**8. A Conexão:**

O Git ajuda a organizar e controlar o código, evitando que alterações sejam perdidas. Já o Docker ajuda a padronizar o ambiente, fazendo com que a aplicação funcione de forma parecida para todos. Um novo desenvolvedor pode baixar o projeto pelo Git, criar sua branch, iniciar o Docker, fazer suas alterações, testar e depois enviar para revisão. Dessa forma, a equipe trabalha de maneira mais organizada e diminui os problemas entre os diferentes computadores.

________________________________________________________________________________

## Parte 3 — Síntese

### Proposta para o CTO

Propomos implementar **Git e Docker** na equipe da TechNova. O Git vai ajudar a controlar as versões do código e evitar a perda de alterações. O Docker vai padronizar os ambientes e diminuir os problemas de “funciona na minha máquina”. Com isso, a equipe poderá trabalhar de forma mais organizada, segura e com menos retrabalho.

