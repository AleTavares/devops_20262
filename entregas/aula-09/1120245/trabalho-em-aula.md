# Trabalho em Aula — Aula 09: Docker Registry (ECR) + IA no CI/CD

**Aluno:** Matheus Mantovani  
**RA:** 1120245  
**Data:** 24/10/2026

---

## Questões de Verificação

### Questão 1 — Estratégia de tagging para rastreabilidade

**Alternativa correta: c) tag com Git SHA (ex: `sha-a1b2c3d`) porque vincula a imagem ao commit exato.**

O problema de rastreabilidade é o seguinte: quando um bug aparece em produção, a primeira pergunta é "qual versão exata está rodando?". Com tag `latest`, essa pergunta não tem resposta — `latest` pode apontar para qualquer commit mais recente, e não há como saber qual build gerou a imagem que está rodando. Com tag de data/hora (`2024-01-15-1430`), você sabe quando foi buildada, mas não qual código gerou aquela build — seria necessário cruzar timestamp com o histórico de commits.

Com Git SHA (`sha-a1b2c3d`), a rastreabilidade é completa e bidirecional: dado o container rodando em produção, você identifica o commit exato com `git show a1b2c3d`, vê o diff exato que introduziu a mudança, e encontra o PR que aprovou aquele código. Para rollback, basta identificar o SHA da versão anterior no console do ECR e fazer pull com aquela tag específica. A imutabilidade é o ponto-chave: uma tag SHA nunca aponta para imagens diferentes em momentos distintos — é sempre o mesmo build, bit a bit.

---

### Questão 2 — Autenticação no Amazon ECR no Learner Lab

**Alternativa correta: b) com `aws ecr get-login-password` passando o token temporário para `docker login` com o usuário `AWS`.**

O ECR não usa usuário e senha estáticos como o Docker Hub. Ele usa tokens temporários gerados pela própria AWS com base nas credenciais de sessão ativas — o que é mais seguro porque o token expira (geralmente em 12 horas) e não há credencial de longa duração para vazar. O comando `aws ecr get-login-password --region us-east-1` solicita esse token à AWS; o resultado é passado via pipe para `docker login --username AWS --password-stdin`, onde `AWS` é literalmente o usuário fixo que o ECR usa para autenticação de Docker.

No contexto do Learner Lab, isso significa que as credenciais temporárias de sessão (incluindo o `AWS_SESSION_TOKEN`) precisam estar configuradas antes do `docker login`. Sem o token de sessão, a chamada à API do ECR falha com erro de autorização. É diferente de uma conta AWS normal, onde usuários IAM têm credenciais de longa duração — no Lab, as credenciais expiram quando a sessão encerra e precisam ser recarregadas.

---

### Questão 3 — Ação com achado CRITICAL no AI Review

**Alternativa correta: b) bloquear o PR (exit 1) e exigir correção antes do merge.**

O quality gate existe exatamente para que achados críticos não sejam ignorados ou esquecidos no fluxo normal de trabalho. Um desenvolvedor apressado pode fechar um comentário de WARNING com a intenção de "corrigir depois" e nunca voltar. Com exit code 1 no job de review quando há um achado CRITICAL, o PR simplesmente não pode ser mergeado até a correção — o GitHub bloqueia o merge enquanto o check está falhando.

Isso não é punição ao desenvolvedor — é proteção do sistema. Os exemplos de CRITICAL — secrets hardcoded no código, `eval()` com input do usuário, SQL construído por concatenação de string — são vulnerabilidades que, se chegarem a produção, têm impacto imediato e potencialmente irreversível. Uma credencial exposta requer rotação emergencial, comunicação de incidente e potencialmente notificação regulatória. O custo de bloquear um PR por algumas horas enquanto a correção é feita é ordens de magnitude menor que o custo de um incidente de segurança em produção.

---

### Questão 4 — Principal limitação do AI code review

**Alternativa correta: c) IA vê apenas o diff do PR, sem entender o contexto completo do sistema e decisões de negócio.**

A IA de review recebe o diff — os arquivos modificados naquele PR — sem acesso ao restante do codebase, à história de decisões arquiteturais, às conversas sobre trade-offs que a equipe teve nos últimos meses, ou ao contexto de negócio que explica por que o código está estruturado de determinada forma. Isso cria blind spots específicos: a IA pode sinalizar como problema uma convenção que faz sentido no contexto do projeto mas parece estranha fora dele, ou pode perder um bug sutil que só é visível ao olhar como dois módulos distantes interagem.

O review humano é insubstituível para decisões arquiteturais ("esse novo endpoint faz sentido na estrutura atual?"), para lógica de negócio complexa ("esse cálculo de desconto está correto segundo as regras de negócio que discutimos?"), e para avaliar se o código está movendo o sistema na direção certa. A IA é excelente para o "arroz com feijão" — verificar padrões conhecidos de segurança, estilo, código morto, secrets — liberando o revisor humano para o trabalho de alto valor.

---

### Questão 5 — Vantagem de publicar imagem no registry

**Alternativa correta: b) garante que a mesma imagem testada no CI é a executada em produção (build once, run anywhere).**

Essa é a premissa fundamental do delivery de containers: o artefato que é testado deve ser exatamente o artefato que vai para produção. Se você builda a imagem de novo no servidor de produção a partir do mesmo código-fonte, teoricamente deveria ser igual — mas na prática não é garantido. Uma dependência de sistema operacional pode ter sido atualizada; o `npm install` pode ter resolvido uma versão de pacote diferente porque o `package-lock.json` foi atualizado entre o CI e o deploy; a imagem base `node:20-alpine` pode ter um patch novo. Essas diferenças são raras mas reais, e são suficientes para introduzir bugs que só aparecem em produção.

Com o ECR como intermediário, o fluxo é determinístico: o CI builda, testa, tageia com o SHA do commit e faz push. O servidor de produção apenas faz pull da exatamente mesma imagem. O binário que passou nos testes unitários, no lint e no build de CI é o mesmo binário que roda em produção — até o último byte. Isso é o que o princípio "build once, run anywhere" significa na prática.

---

## Reflexão da Aula

A aula de ECR + IA no CI/CD foi o fechamento da segunda etapa do pipeline da TechNova. Na aula anterior construímos a verificação de qualidade (lint, test, build); nesta, fechamos o ciclo de entrega: a imagem não mais "nasce e morre" dentro do runner do GitHub Actions, mas passa a existir de forma versionada e durável no ECR, disponível para qualquer servidor fazer pull.

A evolução da IA ao longo do curso foi gradual e intencional, e só fiquei consciente dela nesta aula: da Aula 02 (Kiro interativo, controle total do desenvolvedor) até a Aula 09 (IA automática no pipeline, sem nenhuma intervenção humana). Essa progressão reflete uma mudança real de papéis: o desenvolvedor não mais "usa" a IA — ele define as regras de qualidade, e a IA as executa. É uma delegação com responsabilidade: a IA vai segurar o que você especificar que ela segure, e nada mais. Por isso a qualidade do quality gate — a definição do que é CRITICAL, WARNING e INFO — é tão importante quanto a qualidade do código que ele revisa.