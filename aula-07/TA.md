# Aula 07 — Trabalho Anterior (TA)

## Objetivo

Preparar você para a aula sobre um dos conceitos mais importantes da computação (e da vida profissional): **como resolver problemas complexos dividindo-os em partes menores** — e como isso muda tudo quando trabalhamos com **Inteligência Artificial**.

Ao final desta leitura, você vai entender:

1. Por que problemas grandes são difíceis de resolver "de uma vez só"
2. O que é **decomposição** (dividir para conquistar) e por que ela funciona
3. Por que a **IA erra mais** quando recebe um problema gigante e vago
4. O que é o **Harness** (o "arreio") que damos para a IA trabalhar bem
5. O que é **Spec-Driven Development** e como o Kiro usa isso na prática

> **Tempo estimado de leitura:** ~40 minutos. Leia com calma — na aula vamos praticar tudo isso construindo juntos.

---

## Parte 1 — Por que Problemas Complexos São Difíceis?

### 1.1 Uma história que você já viveu

Imagine que alguém te pede: **"Faça um sistema de e-commerce completo."**

Por onde você começa? Provavelmente sua cabeça trava. É muita coisa ao mesmo tempo: cadastro de usuário, catálogo de produtos, carrinho, pagamento, entrega, e-mail de confirmação... Você olha para essa montanha e não sabe dar o primeiro passo.

Agora imagine que o pedido foi outro: **"Crie uma tela de login com e-mail e senha."**

Bem mais fácil, né? Você já sabe o que fazer. Consegue imaginar a solução inteira na cabeça.

A diferença entre as duas situações **não é a sua capacidade** — é o **tamanho e a clareza do problema**. O primeiro é grande e vago. O segundo é pequeno e específico.

> **A lição:** problemas complexos não são resolvidos "de uma vez". Eles são resolvidos **em pedaços**.

### 1.2 O que é, afinal, um "problema complexo"?

Antes de aprender a resolver, precisamos entender **por que** certos problemas travam a gente. Um problema costuma ser difícil por uma combinação de três fatores:

| Fator | O que significa | Exemplo |
|-------|-----------------|---------|
| **Tamanho** | Tem muitas partes para fazer | Um e-commerce tem dezenas de funcionalidades |
| **Conexões (acoplamento)** | As partes dependem umas das outras | O carrinho depende do catálogo, que depende do cadastro |
| **Incerteza (vaguidão)** | Não está claro o que exatamente é para fazer | "Faça algo bom para os clientes" — bom como? |

Repare numa coisa importante: **complexo não é a mesma coisa que complicado.**

- **Complicado** é algo com muitas peças, mas previsível — como um relógio. Trabalhoso, mas se você seguir o passo a passo, funciona.
- **Complexo** é quando as peças se influenciam de formas difíceis de prever — mexer numa afeta as outras. É aqui que a gente mais se perde.

Quanto mais desses três fatores um problema tem, mais a nossa mente (e a IA, como veremos) sofre para lidar com ele **de uma vez só**.

### 1.3 Por que a nossa mente "trava": carga cognitiva

Existe uma explicação da psicologia para aquele "branco" que dá quando olhamos um problema gigante. Chama-se **carga cognitiva** (*cognitive load*).

A ideia, de forma simples: a nossa **memória de trabalho** — a parte do cérebro que segura as informações enquanto pensamos — tem **capacidade limitada**. Estudos clássicos sugerem que conseguimos manter só um **punhado de coisas** na cabeça ao mesmo tempo (algo em torno de "7, mais ou menos 2" itens, segundo o psicólogo George Miller, em um trabalho famoso de 1956).

Quando um problema exige que você segure **dezenas de detalhes ao mesmo tempo** — cadastro, pagamento, estoque, e-mail, segurança... — você **estoura** essa capacidade. O resultado é aquela sensação de sobrecarga e paralisia.

![Memória de Trabalho](img/ta001.png)

> **A grande sacada:** você não trava por ser incapaz. Você trava porque está tentando segurar coisas demais ao mesmo tempo. A solução não é "pensar mais forte" — é **reduzir quantas coisas você segura de cada vez**. E é exatamente isso que a decomposição faz.

### 1.4 A solução: "Dividir para Conquistar"

Essa estratégia tem nome e é um dos pilares da computação: **"Dividir para Conquistar"** (em inglês, *Divide and Conquer*).

A ideia é antiga — muito antes dos computadores. A expressão vem do latim *divide et impera* e era usada em estratégia militar e política: em vez de enfrentar um exército inteiro de uma vez, você o separa em grupos menores e vence cada um. Na computação, aplicamos o mesmo raciocínio a **problemas**.

O fluxo é este:

![Dividir para Conquistar](img/ta002.png)

São sempre **três movimentos**: **dividir** o problema, **conquistar** (resolver) cada pedaço, e **combinar** os pedaços na solução final.

**Isso não é só teoria de sala de aula — é como programas reais funcionam.** Alguns exemplos que rodam bilhões de vezes por dia no mundo:

- **Busca em uma lista ordenada (busca binária):** para achar um nome numa lista ordenada, você não lê nome por nome. Abre no meio, vê se o que procura está antes ou depois, e **descarta metade** — repetindo isso, acha rapidíssimo. Cada passo divide o problema pela metade.
- **Ordenar uma lista gigante (merge sort):** o computador divide a lista em pedaços pequenos, ordena cada pedacinho (fácil) e depois junta tudo de volta na ordem certa.
- **Carregar uma página da web:** o navegador não baixa tudo num bloco só — divide em partes (texto, imagens, estilos) e trata cada uma.

Você também já usa isso na vida sem perceber: quando estuda para uma prova, não lê o livro inteiro de uma vez — divide em capítulos. Quando organiza uma viagem, separa em "passagem", "hospedagem", "roteiro". **Decompor é a forma natural de vencer a carga cognitiva.**

### 1.5 Por que dividir melhora a eficiência

Quebrar um problema em partes menores traz benefícios concretos:

| Benefício | Por quê acontece |
|-----------|------------------|
| **Cada parte cabe na cabeça** | Um problema pequeno respeita o limite da sua memória de trabalho — você raciocina sobre ele inteiro, sem sobrecarga. |
| **Você erra menos e acha o erro rápido** | Se algo dá errado, o problema está confinado a uma parte pequena. Em vez de procurar uma agulha num palheiro, você procura numa caixinha. |
| **Você testa e valida aos poucos** | Cada parte pode ser conferida antes de seguir. Você descobre problemas cedo, e não no final, com tudo pronto e quebrado. |
| **Você vê progresso** | Cada parte concluída é uma pequena vitória. Isso reduz a ansiedade e mantém a motivação — o oposto da paralisia inicial. |
| **Dá para dividir o trabalho** | Partes independentes podem ser feitas por pessoas diferentes (ou pela IA) ao mesmo tempo. |

> **Analogia:** montar um móvel. Ninguém encaixa todas as peças ao mesmo tempo. Você segue o manual, passo a passo, uma peça de cada vez. Se apertar o parafuso errado, percebe **naquele passo** — não no final, com o móvel inteiro montado e torto.

### 1.6 A parte difícil: dividir BEM

Aqui vai uma verdade que quase ninguém conta: **o desafio não é "dividir", é "dividir bem".** Cortar um problema em pedaços aleatórios não ajuda — pode até piorar.

Uma boa divisão tem duas qualidades:

- **Partes coesas:** cada parte trata de **uma coisa só** e faz sentido sozinha. Ex.: "cadastrar cliente" é uma parte coesa; "cadastrar cliente e também calcular o frete e mandar e-mail" mistura assuntos.
- **Partes pouco acopladas:** as partes dependem **o mínimo possível** umas das outras. Quanto mais independentes, mais fácil resolver e testar cada uma isoladamente.

Você também precisa pensar na **ordem** e nas **dependências**: algumas partes precisam existir antes de outras. Não dá para "fazer uma reserva" antes de "cadastrar a sala". Boa decomposição também é **descobrir essa ordem**.

![Dividir Bem](img/ta003.png)

Não se preocupe em acertar a divisão perfeita de primeira — **decompor é uma habilidade que melhora com a prática**, e nesta aula você vai treinar bastante (inclusive deixando o Kiro ajudar a organizar as partes).

### 1.7 Você já fez isso o bimestre todo

Repare: no Módulo 2, você **nunca** criou a infraestrutura inteira de uma vez. O problemão "colocar a TechNova na nuvem" foi quebrado em partes, uma por aula:

![Você já Fez Isso](img/ta004.png)

Cada aula resolveu **uma parte**, na **ordem certa** (a rede antes do servidor, o servidor antes de modularizar). Se tivéssemos tentado fazer tudo na Aula 03, teria sido um caos impossível de acompanhar. **A decomposição — dividir bem e na ordem certa — foi o que tornou o curso inteiro possível.**

---

## Parte 2 — Decomposição no Mundo da IA

### 2.1 A IA é poderosa, mas tem limites

Ferramentas de IA como o Kiro conseguem escrever código, explicar conceitos e resolver problemas impressionantes. Mas elas têm um comportamento importante que você precisa entender:

> **Quanto maior e mais vago o pedido, maior a chance de a IA errar.**

Quando você pede algo enorme como "crie um sistema completo de e-commerce com tudo funcionando", a IA tenta adivinhar centenas de decisões que você não explicou. E aí acontece o que chamamos de **alucinação**: a IA inventa coisas, mistura tecnologias, esquece partes, ou entrega algo que parece certo mas não funciona.

### 2.2 O que é "alucinação" da IA

**Alucinação** é quando a IA responde com algo que parece confiante e correto, mas está **errado ou inventado**. Exemplos:

- Cita uma função que não existe naquela linguagem
- Usa uma configuração que não é válida
- "Esquece" um pedaço do que você pediu
- Mistura duas soluções incompatíveis

![Alucinação](img/ta005.png)

### 2.3 A mesma regra vale para a IA: dividir para conquistar

Aqui está o insight central desta aula:

> **A IA resolve problemas complexos muito melhor quando você os divide em partes menores — exatamente como um humano.**

![Dividir para Conquistar](img/ta012.png)
No pedido gigante, a IA vai entregar algo grande, difícil de revisar, e provavelmente com erros escondidos. Nos pedidos divididos, cada resposta é **pequena, fácil de validar, e você percebe qualquer erro na hora**.

> **Regra de ouro:** você é o piloto, a IA é o copiloto. Um bom piloto **quebra a rota em etapas** e confere o mapa a cada trecho.

### 2.4 Por que isso funciona (de forma simples)

A IA trabalha com uma espécie de "atenção" limitada — quanto mais coisas você joga de uma vez, mais essa atenção se divide e mais fácil é ela perder detalhes. Ao dar **um problema pequeno por vez**, você concentra toda a "atenção" dela naquele ponto, e o resultado sai mais preciso.

Além disso, quando você divide, **você consegue validar cada etapa**. E validar é o que impede que um erro pequeno vire um problema gigante lá na frente.

---

## Parte 3 — Harness: o "Arreio" que Guia a IA

### 3.1 O que significa "Harness"

A palavra **harness** em inglês significa **arreio** — aquele conjunto de correias que se coloca em um cavalo para **guiá-lo na direção certa**. O cavalo é forte e rápido, mas sem o arreio ele vai para qualquer lugar. O arreio não deixa o cavalo mais fraco; pelo contrário, é justamente ele que transforma a força bruta do animal em movimento **útil e controlado**.

No mundo da IA, **Harness** (às vezes chamado de "AI harness" ou "agent harness") é toda a **camada de estrutura, contexto, regras e ferramentas** que colocamos **ao redor** do modelo de IA para que ele trabalhe de forma **guiada, previsível e confiável** — em vez de sair "correndo para qualquer lado".

É importante entender uma distinção: o **modelo** (a "inteligência" que gera texto) é só uma parte. Sozinho, o modelo apenas recebe um texto e devolve outro texto. O que faz esse modelo virar uma ferramenta realmente útil — que entende seu projeto, segue regras, executa passos e valida resultados — é o **harness ao redor dele**. Quando você usa o Kiro, você não está usando "só um modelo": está usando um modelo **dentro de um harness** bem construído.

![Harness](img/ta006.png)

### 3.2 Por que a IA precisa de um arreio? A "janela de contexto"

Para entender por que o Harness importa tanto, você precisa conhecer um limite técnico das IAs: a **janela de contexto** (*context window*).

A janela de contexto é a **quantidade de texto que a IA consegue "olhar" de uma só vez** para produzir a resposta — é como o "campo de visão" ou a "memória de curto prazo" do modelo. Tudo que está dentro da janela, a IA considera. O que fica de fora, ela **simplesmente não vê**.

Isso tem duas consequências diretas:

1. **A IA não "lembra" de tudo para sempre.** Se a conversa fica muito longa, ou se você joga um problema gigantesco de uma vez, informações importantes podem "escorregar para fora" da janela — e a IA age como se elas não existissem. É parecido com a **carga cognitiva** que vimos na Parte 1: assim como a nossa memória de trabalho transborda, a janela de contexto da IA também tem limite.

2. **Contexto de qualidade vale mais que contexto em quantidade.** Encher a janela com informação irrelevante "empurra" para fora o que importa e ainda distrai o modelo. Um bom Harness coloca na janela **a informação certa, na hora certa** — nem de menos (a IA adivinha) nem de mais (a IA se perde).

> **A ligação:** o Harness existe, em boa parte, para **gerenciar a janela de contexto** — garantir que a IA sempre tenha em vista o que precisa para aquele passo específico, e nada além disso. Por isso "escopo pequeno" e "um passo por vez" funcionam tão bem: eles respeitam o limite de atenção da IA.

### 3.3 Do que é feito um bom Harness

Um bom "arreio" para a IA combina cinco elementos. Repare que cada um resolve um problema específico:

| Elemento | O que é | Que problema evita |
|----------|---------|--------------------|
| **Contexto** | Informar à IA sobre o projeto, as tecnologias, o objetivo e as restrições | Evita que a IA **adivinhe** e invente premissas erradas |
| **Estrutura** | Um caminho claro de etapas (um processo), em vez de um pedido solto | Evita que a IA faça tudo de qualquer jeito, fora de ordem |
| **Regras** | Limites explícitos do que pode e não pode (ex: "use só a biblioteca X", "não acesse a internet") | Evita que a IA tome decisões proibidas ou perigosas |
| **Ferramentas** | Dar à IA acesso controlado a recursos (ler arquivos, rodar comandos, testar) | Permite que ela **verifique a realidade** em vez de só "achar" |
| **Validação** | Pontos de conferência entre uma etapa e outra (testes, revisão humana) | Impede que um erro pequeno passe adiante e contamine o resto |
| **Escopo pequeno** | Cada pedido foca em uma parte, não no todo | Respeita a janela de contexto e reduz a chance de alucinação |

Note que **você já usa um harness sem chamar por esse nome**: quando você dá contexto no prompt, define regras ("não use tal coisa"), pede um passo por vez e confere o resultado, você **está construindo o arreio manualmente**. Ferramentas como o Kiro fazem grande parte disso por você, de forma organizada.

### 3.4 Harness ≠ mágica: o profissional continua no comando

Um ponto essencial: o Harness **reduz** o risco de erro, mas **não elimina**. Ele é o que torna a IA confiável o suficiente para ser útil, mas quem garante a qualidade final é **você**. O arreio guia o cavalo, mas quem decide o destino é o cavaleiro.

> **Conexão com a Parte 2:** o Harness é justamente o que nos permite **dividir o problema e guiar a IA por cada parte** de forma organizada, respeitando a janela de contexto. Decompor (dividir) + Harness (guiar) = trabalhar bem com IA. Na próxima parte, veremos como o Kiro transforma tudo isso em um método concreto: o **Spec-Driven**.

---

## Parte 4 — Spec-Driven Development

### 4.1 O que é "Spec-Driven"

**Spec** é a abreviação de **specification** (especificação). Uma especificação é uma **descrição clara e combinada do que deve ser feito, antes de sair fazendo**. Não é código, não é o produto final — é o **acordo** sobre o que se quer construir.

**Spec-Driven Development** ("desenvolvimento guiado por especificação") é uma forma de trabalhar em que você **primeiro descreve bem o problema e o plano**, e **só depois** parte para a implementação. É o oposto de "sair codando sem pensar".

Essa ideia **não nasceu com a IA**. Na engenharia de software, há décadas se sabe que **pensar antes de construir** economiza tempo e evita desastres. Nenhum engenheiro constrói uma ponte "improvisando" — primeiro vem o projeto, depois a obra. Com software é igual: escrever o que se quer, revisar, e só então implementar. O que a IA fez foi tornar esse método ainda mais valioso — porque, como vimos, a IA precisa de um bom Harness (contexto + estrutura) para não alucinar, e uma especificação é exatamente isso.

#### O custo de corrigir tarde

Existe um princípio muito conhecido na engenharia de software: **quanto mais tarde você descobre um erro, mais caro é consertá-lo.** Um mal-entendido que seria resolvido com uma frase na fase de planejamento pode virar horas (ou dias) de retrabalho se só for descoberto com o sistema todo pronto.

![Custo Corrigindo Tarde](img/ta007.png)

O Spec-Driven ataca exatamente isso: ao **investir um pouco de tempo planejando e revisando no início**, você derruba o custo dos erros — porque os pega quando ainda são só palavras num documento, e não código quebrado.

#### O que é uma boa especificação

Uma boa spec responde três perguntas, em ordem, separando bem cada uma:

- **O QUÊ** (Requisitos): o que o sistema precisa fazer, do ponto de vista de quem vai usar. Ainda **sem** decidir como.
- **COMO** (Design): de que forma vamos construir — estrutura, arquivos, decisões técnicas.
- **EM QUE PASSOS** (Tarefas): a sequência de pedaços pequenos para chegar lá.

Separar "o quê" de "como" é mais poderoso do que parece: primeiro combinamos **o objetivo** (fácil de todos entenderem e concordarem), e só depois discutimos **a solução técnica**. Misturar os dois é uma das maiores fontes de confusão em projetos.

![Spec-Driven](img/ta008.png)

### 4.2 Como o Kiro usa Spec-Driven

O Kiro tem um modo chamado **Spec** que aplica exatamente esse conceito. Quando você descreve o que quer, ele te guia por **três documentos**, em ordem:

![Kiro Spec](img/ta009.png)

1. **Requisitos** — o Kiro escreve, em linguagem clara, **o que** o sistema deve fazer. Você revisa e corrige antes de avançar.
2. **Design** — o Kiro descreve **como** vai construir (estrutura, arquivos, decisões técnicas). Você revisa de novo.
3. **Tarefas** — o Kiro quebra tudo em uma **lista de passos pequenos**. Você aprova.

Só depois disso o Kiro implementa — **uma tarefa por vez**, permitindo que você valide cada pedaço.

### 4.3 Por que o Spec-Driven combate a alucinação

Repare como o Spec-Driven é a **decomposição da Parte 2 transformada em método**:

- Em vez de um pedido gigante, você tem **três etapas de planejamento** + **tarefas pequenas**
- Em vez de a IA adivinhar, ela **escreve o que entendeu** (requisitos) e **você corrige** antes de codar
- Em vez de descobrir erros no final, você **valida a cada tarefa**

![Por que Spec-Driven](img/ta010.png)

### 4.4 O ciclo completo, resumido

![Ciclo Completo](img/ta011.png)

---

## Parte 5 — Fechando as Ideias

Vamos amarrar tudo o que você leu:

1. **Problemas complexos** travam a gente quando tentamos resolvê-los de uma vez.
2. **Decompor** (dividir para conquistar) torna cada parte fácil, reduz erros e mostra progresso.
3. A **IA também erra mais** com problemas grandes e vagos — isso é a **alucinação**.
4. Por isso, dividir o problema em partes menores faz a **IA trabalhar muito melhor**.
5. O **Harness** é o "arreio" que guia a IA: contexto, estrutura, regras, validação e escopo pequeno.
6. O **Spec-Driven** (usado pelo Kiro) é o Harness na prática: Requisitos → Design → Tarefas → implementar validando cada passo.

> **Na aula:** vamos pegar um problema propositalmente complexo e resolvê-lo **juntos**, ao vivo, usando o Kiro em modo Spec — mostrando na prática como a decomposição faz a diferença.

---

## Questões de Verificação

Marque a alternativa correta em cada questão. O gabarito comentado está logo depois — mas tente responder **antes** de olhar!

### Questão 1
Por que resolver "faça um sistema de e-commerce completo" é mais difícil do que "crie uma tela de login com e-mail e senha"?

- a) Porque o e-commerce usa linguagens de programação mais difíceis que o login.
- b) Porque o primeiro pedido é grande e vago, exigindo muitas decisões ao mesmo tempo, enquanto o segundo é pequeno e específico.
- c) Porque uma tela de login não é considerada um problema de programação.
- d) Porque só é possível resolver problemas grandes com uma equipe muito grande.

### Questão 2
Qual afirmação descreve corretamente uma **alucinação** de IA e uma situação que a torna mais provável?

- a) É quando a IA fica lenta; ocorre mais quando o computador tem pouca memória.
- b) É quando a IA se recusa a responder; ocorre mais quando o pedido é pequeno demais.
- c) É quando a IA responde algo que parece correto mas está errado ou inventado; ocorre mais com pedidos grandes e vagos.
- d) É quando a IA repete a mesma resposta; ocorre apenas quando não há conexão com a internet.

### Questão 3
No contexto de trabalhar com IA, o que é um **Harness** (arreio)?

- a) Um tipo de modelo de IA mais avançado que substitui os modelos comuns.
- b) A camada de estrutura, contexto, regras e validação que colocamos ao redor da IA para guiá-la de forma confiável.
- c) Um comando que faz a IA responder mais rápido.
- d) Uma técnica para deixar os prompts o mais longos possível.

### Questão 4
Qual é a ordem correta das três etapas do modo **Spec** do Kiro, e por que revisar cada uma ajuda?

- a) Tarefas → Design → Requisitos; revisar ajuda a deixar o código mais bonito.
- b) Design → Requisitos → Tarefas; revisar serve apenas para documentar depois de pronto.
- c) Requisitos → Design → Tarefas; revisar cada etapa permite corrigir o rumo cedo, antes de a IA implementar algo errado.
- d) Requisitos → Tarefas → Design; revisar não faz diferença no resultado final.

### Questão 5
O que é **carga cognitiva** e qual sua relação com "travar" diante de um problema grande?

- a) É a quantidade de energia elétrica que o cérebro gasta; não tem relação com a dificuldade do problema.
- b) É o limite de informações que a memória de trabalho segura ao mesmo tempo; um problema grande estoura esse limite e a mente trava.
- c) É a velocidade com que aprendemos algo novo; quanto maior, mais fácil qualquer problema fica.
- d) É um conceito exclusivo de IA e não se aplica a seres humanos.

### Questão 6
O que significa dividir um problema em partes **coesas** e **pouco acopladas**?

- a) Coesas = partes grandes; pouco acopladas = partes que fazem várias coisas ao mesmo tempo.
- b) Coesas = cada parte faz uma coisa só e faz sentido sozinha; pouco acopladas = dependem o mínimo possível umas das outras.
- c) Coesas = partes escritas na mesma linguagem; pouco acopladas = partes escritas em linguagens diferentes.
- d) Os dois termos significam a mesma coisa: dividir em muitas partes.

### Questão 7
Por que dividir um problema em partes menores também ajuda a IA a trabalhar melhor?

- a) Porque a IA cobra menos por pedidos pequenos.
- b) Porque pedidos pequenos e específicos concentram a "atenção" da IA, reduzem a alucinação e permitem validar cada parte.
- c) Porque a IA só entende pedidos de até 10 palavras.
- d) Porque dividir o problema faz a IA responder sem precisar de contexto nenhum.

### Questão 8
Segundo o princípio visto na aula, quando um erro é mais **barato** de corrigir?

- a) Quando é descoberto com o sistema já pronto e entregue.
- b) Quando é descoberto durante a implementação do código.
- c) Quando é descoberto ainda na fase de planejamento/especificação.
- d) O custo de corrigir um erro é sempre o mesmo, não importa quando ele é descoberto.

---

> As respostas das questões serão discutidas no início da aula.

---

## Referências

Materiais e conceitos que embasaram este texto (leitura opcional para aprofundar):

1. **MILLER, George A.** *The Magical Number Seven, Plus or Minus Two: Some Limits on Our Capacity for Processing Information.* Psychological Review, 1956. — Origem clássica da ideia de que a memória de trabalho tem capacidade limitada (base do conceito de carga cognitiva).
2. **SWELLER, John.** *Cognitive Load Theory.* — Teoria da carga cognitiva aplicada ao aprendizado e à resolução de problemas.
3. **CORMEN, T.; LEISERSON, C.; RIVEST, R.; STEIN, C.** *Algoritmos: Teoria e Prática (Introduction to Algorithms).* — Referência sobre "Dividir para Conquistar" (Divide and Conquer) e exemplos como busca binária e merge sort.
4. **WING, Jeannette M.** *Computational Thinking.* Communications of the ACM, 2006. — Artigo seminal sobre pensamento computacional, cujos pilares incluem a **decomposição**.
5. **BROOKS, Frederick P.** *The Mythical Man-Month.* — Clássico da engenharia de software sobre complexidade e o custo de mudanças em projetos.
6. **HUNT, A.; THOMAS, D.** *The Pragmatic Programmer.* — Boas práticas de resolução incremental de problemas e design com baixo acoplamento e alta coesão.
7. **Documentação oficial do Kiro** — Modo Spec (Requisitos → Design → Tarefas) e steering/contexto. Disponível em: [https://kiro.dev/docs/](https://kiro.dev/docs/)
8. **Documentação da Anthropic — Prompt Engineering & Context Windows.** — Conceitos de janela de contexto e boas práticas de prompting. Disponível em: [https://docs.anthropic.com/](https://docs.anthropic.com/)
9. **IBM — What are AI hallucinations?** — Explicação acessível sobre alucinações de IA. Disponível em: [https://www.ibm.com/topics/ai-hallucinations](https://www.ibm.com/topics/ai-hallucinations)

> **Observação:** os conceitos foram adaptados para linguagem introdutória de ADS. As referências servem para quem quiser se aprofundar na teoria original.

---

> **Ambiente do curso:** esta aula é **conceitual e prática com o Kiro** — o foco é aprender a decompor problemas e a guiar a IA. Traga suas dúvidas e venha preparado para construir junto na aula!
