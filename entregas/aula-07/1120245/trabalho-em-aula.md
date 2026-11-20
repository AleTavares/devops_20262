# Trabalho em Aula — Aula 07: Spec-Driven Development + IA

**Aluno:** Matheus Mantovani  
**RA:** 1120245  
**Data:** 15/09/2026

---

## Questões de Verificação

### Questão 1 — Problemas grandes vs problemas pequenos (Q1 do TA)

**Alternativa correta: b) porque o primeiro pedido é grande e vago, exigindo muitas decisões ao mesmo tempo, enquanto o segundo é pequeno e específico.**

A diferença não é de linguagem nem de tecnologia — é de carga cognitiva. "Faça um sistema de e-commerce completo" é vago em dois sentidos: em tamanho (são dezenas de funcionalidades) e em especificação (o que exatamente cada funcionalidade deve fazer?). Para começar a resolver, seria necessário tomar centenas de micro-decisões ao mesmo tempo: qual framework de pagamento? Como funciona o fluxo de cancelamento? O estoque é reservado no momento de adicionar ao carrinho ou no pagamento? A mente trava não por incapacidade, mas porque a memória de trabalho — que George Miller estimou em cerca de 7 itens — transborda antes de chegar a qualquer passo concreto.

"Crie uma tela de login com e-mail e senha" já define o escopo completamente. Consigo visualizar a solução inteira, estimar o esforço e começar imediatamente. Essa é a lição mais operacional da aula: a qualidade do pensamento depende da qualidade da decomposição. Um problema grande não é intrinsecamente mais difícil — ele só precisa ser quebrado em partes menores antes de ser atacado.

---

### Questão 2 — Alucinação de IA (Q2 do TA)

**Alternativa correta: c) é quando a IA responde algo que parece correto mas está errado ou inventado; ocorre mais com pedidos grandes e vagos.**

Alucinação é o fenômeno em que o modelo gera uma resposta confiante e coerente na forma, mas incorreta no conteúdo — pode ser uma função que não existe na linguagem, uma configuração inválida, ou uma mistura de duas soluções incompatíveis. O que torna alucinação particularmente perigosa é que ela não parece errada à primeira vista: o código gerado é sintaticamente válido, o texto está bem escrito, as explicações soam plausíveis.

A probabilidade de alucinação aumenta quando o pedido é grande e vago porque o modelo precisa "adivinhar" muitas decisões não especificadas. Com um pedido de e-commerce completo, o modelo não tem como saber qual biblioteca de pagamento você usa, qual ORM, qual convenção de rotas — então ele inventa premissas. Cada premissa inventada é uma potencial alucinação. Com um pedido pequeno e específico, as decisões são poucas e claramente definidas, reduzindo drasticamente o espaço para invenção.

---

### Questão 3 — O que é Harness (Q3 do TA)

**Alternativa correta: b) a camada de estrutura, contexto, regras e validação que colocamos ao redor da IA para guiá-la de forma confiável.**

A analogia do arreio é precisa: o cavalo é o modelo de IA, que por si só é poderoso mas indisciplinado. O Harness não substitui o poder do modelo — ele o canaliza. Sem contexto, a IA adivinha. Sem regras, toma decisões proibidas. Sem validação, erros pequenos se propagam. Sem escopo definido, a janela de contexto transborda com informação irrelevante.

O que me pareceu mais revelador foi entender que o Harness é o que transforma o modelo em ferramenta. O Kiro não é "o modelo Claude" — é o modelo Claude dentro de um Harness cuidadosamente construído: ele conhece os arquivos do projeto (contexto), segue um processo definido de Requisitos → Design → Tarefas (estrutura), tem acesso controlado a ferramentas como leitura de arquivos e execução de comandos, e valida cada etapa antes de avançar. Quando usamos o Kiro para gerar Terraform ou Docker Compose, estamos beneficiando do Harness tanto quanto do modelo.

---

### Questão 4 — Ordem do modo Spec do Kiro (Q4 do TA)

**Alternativa correta: c) Requisitos → Design → Tarefas; revisar cada etapa permite corrigir o rumo cedo, antes de a IA implementar algo errado.**

A ordem não é arbitrária — ela reflete o princípio de que erros são mais baratos de corrigir quanto mais cedo são descobertos. Requisitos primeiro porque é a etapa mais barata de corrigir: se o Kiro entendeu errado o que deve ser feito, uma frase no documento de requisitos custa zero e ajusta toda a direção. Se esse mal-entendido só for descoberto na fase de Design, já custa mais — toda a arquitetura pode precisar ser redesenhada. Se for descoberto durante a implementação, custa muito mais — código foi escrito, testado, talvez até commitado, e precisa ser refeito.

Separar "o quê" (Requisitos) de "como" (Design) é igualmente importante. Primeiro combinamos o objetivo em linguagem que qualquer stakeholder entende — sem termos técnicos, sem escolhas de tecnologia. Só depois, com o objetivo validado, discutimos a solução técnica. Isso evita o erro clássico de ficar debatendo qual framework usar antes de ter clareza sobre o que o sistema precisa fazer.

---

### Questão 5 — Carga cognitiva (Q5 do TA)

**Alternativa correta: b) é o limite de informações que a memória de trabalho segura ao mesmo tempo; um problema grande estoura esse limite e a mente trava.**

A teoria da carga cognitiva de John Sweller explica o mecanismo por trás de uma experiência que todos conhecemos mas raramente nomeamos. A memória de trabalho — a parte do cérebro que processa informação ativa — tem capacidade limitada. Quando um problema exige segurar dezenas de variáveis interdependentes simultaneamente (cadastro depende de autenticação, que depende de banco, que depende de infraestrutura, que depende de...), o limite é atingido e o processamento efetivo para.

A implicação prática para o nosso trabalho com Terraform e pipelines de CI/CD é direta: a razão pela qual este curso funciona é que cada aula apresenta uma parte do problema da TechNova, naquela ordem. Não seria possível aprender VPC, RDS, Remote State, Módulos, GitHub Actions e ECR ao mesmo tempo — a carga cognitiva seria esmagadora. A decomposição do curso espelha exatamente o que precisamos fazer com nossos próprios problemas.

---

### Questão 6 — Coesão e baixo acoplamento (Q6 do TA)

**Alternativa correta: b) coesas = cada parte faz uma coisa só e faz sentido sozinha; pouco acopladas = dependem o mínimo possível umas das outras.**

Esses dois critérios são o que distingue uma boa decomposição de uma decomposição que simplesmente divide o problema em pedaços maiores. Uma parte coesa tem uma responsabilidade clara e única — se você precisar mudar como o pagamento funciona, só precisa mexer no módulo de pagamento, sem tocar no módulo de catálogo. Uma parte pouco acoplada expõe apenas o que precisa expor — o módulo de pagamento não precisa saber nada sobre como os produtos estão organizados no catálogo, só precisa saber o valor total.

No Terraform, isso se traduz diretamente na estrutura de módulos: um módulo VPC é coeso porque cuida só de rede (VPC, subnets, route tables, IGW). É pouco acoplado porque expõe apenas `vpc_id` e `subnet_ids` como outputs — os módulos que usam a VPC não precisam saber nada sobre como ela foi criada internamente. Quando a criação de subnets muda, apenas o módulo VPC é atualizado. Quem o consome não sabe nem que houve mudança.

---

### Questão 7 — Por que dividir ajuda a IA (Q7 do TA)

**Alternativa correta: b) porque pedidos pequenos e específicos concentram a "atenção" da IA, reduzem a alucinação e permitem validar cada parte.**

O modelo de IA tem uma "janela de contexto" — a quantidade de texto que consegue considerar de uma vez. Um pedido gigante pode ultrapassar essa janela ou distribuir a atenção do modelo por tantos detalhes que coisas importantes "escorregam". Mais do que isso, um pedido grande obriga o modelo a tomar dezenas de decisões implícitas sem feedback — e cada decisão tomada sem validação é um potencial ponto de alucinação que se propaga para as decisões seguintes.

Com pedidos pequenos, cada resposta é curta o suficiente para ser lida e validada em segundos. Se o Kiro errou ao entender a estrutura de uma variável no módulo VPC, eu corrijo antes de ele usar aquela variável como input do módulo Security Group. O erro não contamina o restante. Essa é a mesma razão pela qual commits atômicos são melhores que commits gigantes: mudanças pequenas são fáceis de revisar, fáceis de reverter e fáceis de entender no histórico.

---

### Questão 8 — Quando o erro é mais barato (Q8 do TA)

**Alternativa correta: c) quando é descoberto ainda na fase de planejamento/especificação.**

O gráfico exponencial do custo de correção ao longo do ciclo de desenvolvimento é uma das descobertas mais impactantes da engenharia de software — e continua verdadeiro décadas depois de ter sido documentado por Barry Boehm. Um requisito mal entendido corrigido num documento de texto custa minutos. O mesmo requisito mal entendido descoberto depois que o código foi escrito custa horas de reescrita. Descoberto em produção, pode custar migração de dados, comunicação com clientes afetados, hotfix emergencial e noites sem dormir.

O Spec-Driven Development ataca exatamente esse custo ao criar pontos de verificação explícitos antes da implementação. Quando o Kiro escreve os Requisitos e eu reviso antes de prosseguir, estou pagando o menor custo possível para garantir que o que vai ser construído é o que precisa ser construído. Essa validação antecipada não é burocracia — é a decisão mais econômica de todo o processo de desenvolvimento.

---

## Reflexão da Aula

A aula de Spec-Driven Development foi, paradoxalmente, a mais abstrata do curso até agora e ao mesmo tempo a mais prática. Abstrata porque não escrevemos uma linha de Terraform ou shell script — toda a aula foi sobre como pensar antes de agir. Prática porque os princípios discutidos são o que explica por que tudo que fizemos nas aulas anteriores funcionou: cada aula foi uma decomposição de um problema maior, numa ordem específica, com validação ao final de cada etapa.

O que ficou de mais concreto para mim foi entender o Harness não como uma ferramenta, mas como um comportamento. Sempre que uso o Kiro (ou qualquer IA) bem, estou aplicando Harness: dando contexto antes de pedir, sendo específico sobre o que quero, validando antes de continuar, mantendo o escopo pequeno. Sempre que tenho um resultado ruim — código que não faz sentido, alucinações, respostas genéricas demais — foi porque não estruturei bem o pedido. A responsabilidade pela qualidade do output da IA é compartilhada: o modelo faz sua parte, e eu faço a minha preparando o pedido com a qualidade que o problema merece.