# Laboratório Interativo — Domando um Problema Complexo com o Kiro (Spec)

> **Formato:** este é um **laboratório guiado e construído ao vivo**. O professor conduz cada passo no projetor e os alunos acompanham fazendo junto na própria máquina. A ideia não é "copiar código pronto", e sim **ver o processo de pensamento**: como pegar um problema grande e assustador e transformá-lo em partes pequenas que a IA resolve bem.

---

## O que vamos aprender fazendo

- Pegar um problema **propositalmente complexo** e sentir a dificuldade de resolvê-lo "de uma vez"
- Ver o que acontece quando pedimos **tudo de uma vez** para a IA (o "jeito errado")
- Usar o **modo Spec do Kiro** para decompor: **Requisitos → Design → Tarefas**
- Implementar **uma tarefa de cada vez**, validando cada pedaço
- Sentir na prática por que **dividir para conquistar** deixa a IA muito mais precisa

> **Este laboratório NÃO usa AWS.** Vamos construir uma pequena API em **Node.js** que roda na sua máquina. O objetivo é o **método de pensar**, não a tecnologia.

---

## Pré-requisitos

- **Kiro** aberto e funcionando
- **Node.js** instalado (confira com `node --version`)
- Um terminal e uma pasta vazia para o projeto

---

## O Problema (propositalmente complexo)

O CTO da TechNova pediu um **sistema de fidelidade**. Veja como o pedido chega — grande e vago, do jeito que a vida real entrega:

> *"Quero um sistema de pontos de fidelidade: o cliente se cadastra, acumula pontos a cada compra, pode consultar o saldo, pode resgatar prêmios quando tiver pontos suficientes, e tudo isso precisa ter histórico. Ah, e valida os dados pra ninguém burlar."*

Olhe para isso e responda mentalmente: **por onde você começaria?** Guarde essa sensação de "travou" — é exatamente ela que vamos resolver.

---

## Parte 0 — Preparar o terreno

No terminal, crie a pasta do projeto e abra no Kiro:

```bash
mkdir fidelidade-technova
cd fidelidade-technova
npm init -y
npm install express

# Abrir a pasta no Kiro
kiro .
```

> **Professor:** com a pasta aberta no Kiro, explique que vamos trabalhar com uma API bem simples (Express) só para ter algo concreto para a IA construir. O foco é o **processo**, não o Express.

---

## Parte 1 — O jeito ERRADO (para sentir o problema)

Vamos **de propósito** fazer do jeito ruim primeiro, para todo mundo ver o que acontece.

No chat do Kiro (modo normal/Vibe), peça tudo de uma vez:

> **Prompt (ruim, proposital):**
> "Crie um sistema completo de fidelidade com cadastro de cliente, acúmulo de pontos, consulta de saldo, resgate de prêmios, histórico e validações. Faça tudo funcionar."

**Observem juntos** o que acontece:

- A resposta vem grande e difícil de acompanhar
- Provavelmente faltam pedaços, ou aparecem coisas que ninguém pediu
- Fica difícil saber se aquilo **funciona** de verdade
- Se algo estiver errado, onde está o erro? Difícil dizer.

> **Discussão rápida (professor puxa):** "Vocês confiariam nisso? Como testariam? Onde procurariam um bug?" — a resposta honesta é: é uma bagunça difícil de validar. Isso é o **problema grande demais** gerando **alucinação e insegurança**.

**Não vamos usar esse código.** Ele serviu só para sentir a dor. Apague se algo foi criado.

---

## Parte 2 — Iniciando o modo Spec (o jeito CERTO)

Agora vamos guiar a IA com um **arreio** (Harness). No Kiro, inicie uma **sessão Spec**.

Descreva o **mesmo problema**, mas agora deixando o Kiro **organizar antes de codar**:

> **Prompt (bom, para a Spec):**
> "Quero criar uma API simples em Node.js com Express para um sistema de fidelidade da TechNova. As funcionalidades são: cadastrar cliente, acumular pontos por compra, consultar saldo de pontos, resgatar um prêmio (se tiver pontos suficientes) e ver o histórico de operações. Os dados podem ficar em memória (sem banco, por enquanto). Quero validações básicas nos dados de entrada."

O Kiro vai começar a montar os **Requisitos**. **Ainda não implemente nada.**

> **Professor:** mostre que o Kiro NÃO saiu codando. Ele parou para **entender e organizar** primeiro. Esse "freio" é o começo do Harness.

---

## Parte 3 — Revisar os REQUISITOS (o quê)

O Kiro apresenta um documento de **Requisitos** — a lista clara do **o quê** o sistema deve fazer.

**Revisem juntos, em voz alta.** Para cada funcionalidade, perguntem:

- Isso é realmente o que queremos?
- Está faltando alguma coisa?
- Tem algo aqui que **não** pedimos?

Exemplos de ajustes que a turma pode decidir pedir ao Kiro:

> "Nos requisitos, deixe claro que o cadastro precisa de nome e e-mail, e o e-mail não pode repetir."

> "Adicione o requisito de que resgatar um prêmio com pontos insuficientes deve retornar um erro claro."

> **Ponto-chave para a turma:** aqui a IA **escreveu o que entendeu**, e nós **corrigimos antes de ela codar**. Isso é o que evita ela sair na direção errada. Compare com a Parte 1, onde ela já tinha "adivinhado" tudo sozinha.

Só avancem quando os requisitos estiverem do jeito que a turma concordou.

---

## Parte 4 — Revisar o DESIGN (como)

Aprovados os requisitos, o Kiro gera o **Design** — **como** o sistema será construído.

**Revisem juntos:**

- Quais arquivos ele vai criar? A estrutura faz sentido?
- Como os dados vão ficar guardados (em memória, por enquanto)?
- Quais serão as **rotas** da API? (ex: `POST /clientes`, `GET /clientes/:id/saldo`, ...)

Se algo estiver confuso ou grande demais, peça para simplificar:

> "Mantenha o design simples: um único arquivo `server.js` para começar, com as rotas separadas por comentários. Podemos organizar melhor depois."

> **Ponto-chave:** repare que ainda **não escrevemos código**. Estamos decidindo o **caminho** com calma. É muito mais barato mudar de ideia agora (num texto) do que depois (com código pronto e quebrado).

---

## Parte 5 — Revisar as TAREFAS (os passos pequenos)

Agora vem a parte mais importante para o nosso tema: o Kiro quebra tudo em uma **lista de tarefas pequenas**.

Deve parecer com algo assim:

```
[ ] 1. Criar o servidor Express básico (rota de teste "/")
[ ] 2. Criar cadastro de cliente (POST /clientes) com validação de nome e e-mail
[ ] 3. Impedir e-mail duplicado no cadastro
[ ] 4. Registrar compra e acumular pontos (POST /clientes/:id/compras)
[ ] 5. Consultar saldo de pontos (GET /clientes/:id/saldo)
[ ] 6. Resgatar prêmio se houver pontos suficientes (POST /clientes/:id/resgates)
[ ] 7. Retornar erro claro em resgate sem pontos suficientes
[ ] 8. Consultar histórico de operações (GET /clientes/:id/historico)
```

**Observem juntos:** o problema "gigante e assustador" do começo agora é uma **lista de passos pequenos**, cada um fácil de entender e de testar. **Isto é "dividir para conquistar" na prática.**

> **Professor:** faça o paralelo direto com o TA — cada tarefa é uma "parte menor". A IA vai focar em uma por vez, e nós validamos cada uma.

---

## Parte 6 — Implementar UMA tarefa de cada vez

Agora sim, mão na massa — mas **com controle**. Peça ao Kiro para executar **apenas a primeira tarefa**.

### Ciclo que vamos repetir para cada tarefa:

```
1. Kiro implementa UMA tarefa
2. A gente LÊ o que ele fez (é pouco código, dá pra entender tudo)
3. A gente TESTA (roda e verifica)
4. Se estiver ok → marca a tarefa e vai para a próxima
5. Se estiver errado → corrige AGORA, antes de seguir
```

### Exemplo — Tarefa 1 (servidor básico)

Deixe o Kiro implementar a tarefa 1. Depois, no terminal:

```bash
node server.js
```

Em outro terminal (ou no navegador), teste:

```bash
curl http://localhost:3000/
```

Funcionou? A rota respondeu? **Ótimo — validamos a parte 1.** Marque a tarefa como concluída no Kiro e siga.

### Exemplo — Tarefa 2 (cadastro de cliente)

Deixe o Kiro implementar. Depois teste:

```bash
curl -X POST http://localhost:3000/clientes \
  -H "Content-Type: application/json" \
  -d '{"nome": "Ana", "email": "ana@email.com"}'
```

Testem também o **erro proposital** (validação):

```bash
# Sem e-mail — deve dar erro de validação
curl -X POST http://localhost:3000/clientes \
  -H "Content-Type: application/json" \
  -d '{"nome": "Ana"}'
```

> **Ponto-chave:** cada tarefa é validada **isoladamente**. Se a validação não funcionou, sabemos exatamente onde está o problema — na tarefa 2, que acabamos de fazer. Compare com a Parte 1, onde um erro estaria escondido no meio de um monte de código.

### Continuem o ciclo

Sigam implementando e testando **uma tarefa por vez** (compra → saldo → resgate → histórico), sempre no ritmo: **implementa → lê → testa → valida → próxima**. O professor conduz o quanto o tempo permitir; o restante fica como referência.

---

## Parte 7 — Fechamento: o que aconteceu aqui?

Comparem, em voz alta, os dois caminhos que vivemos hoje:

| | Parte 1 (tudo de uma vez) | Partes 2 a 6 (Spec / dividido) |
|---|---|---|
| A IA entendeu o pedido? | Adivinhou muita coisa | Escreveu e nós corrigimos |
| Deu pra revisar? | Difícil (muito código junto) | Fácil (pouco código por vez) |
| Achar erros | Complicado | Simples (erro fica na tarefa atual) |
| Confiança no resultado | Baixa | Alta |
| Sensação | "Travei / será que funciona?" | "Sob controle, um passo por vez" |

> **A grande lição:** a IA não ficou "mais inteligente" na segunda vez. **Nós ficamos mais inteligentes no jeito de usá-la.** Dividimos o problema, demos estrutura (Harness) e validamos cada parte (Spec-Driven). É assim que se resolve o complexo: **transformando-o em muitos pequenos.**

---

## Checklist do Laboratório

Ao final, você deve ter vivenciado:

- [ ] Sentir a dificuldade de um pedido grande e vago (Parte 1)
- [ ] Iniciar uma Spec no Kiro para o mesmo problema (Parte 2)
- [ ] Revisar e ajustar os **Requisitos** (Parte 3)
- [ ] Revisar e ajustar o **Design** (Parte 4)
- [ ] Ver o problema virar uma **lista de tarefas pequenas** (Parte 5)
- [ ] Implementar e **testar tarefa por tarefa** (Parte 6)
- [ ] Comparar os dois caminhos e entender por que dividir funciona melhor (Parte 7)

---

## Dica de Ouro para levar para a vida

> Sempre que um problema parecer **grande demais** — no trabalho, num projeto, numa prova, ou pedindo algo para uma IA — pare e pergunte:
>
> **"Quais são as partes menores disto?"**
>
> Resolver as partes pequenas, uma de cada vez, é o segredo para resolver qualquer coisa grande. E é também o segredo para usar IA sem cair em alucinação.
