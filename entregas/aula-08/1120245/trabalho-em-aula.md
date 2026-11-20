# Trabalho em Aula — Aula 08: GitHub Actions e CI Pipelines

**Aluno:** Matheus Mantovani  
**RA:** 1120245  
**Data:** 22/09/2026

---

## Questões de Verificação

### Questão 1 — O que dispara um workflow do GitHub Actions

**Alternativa correta: b) eventos configurados no campo `on:` do YAML, como push, pull_request ou workflow_dispatch.**

O campo `on:` é o ponto de entrada de qualquer workflow — sem ele, o arquivo YAML existe mas nunca roda. Os eventos são disparados pelo GitHub automaticamente quando a condição configurada ocorre: um `push` para a branch `main`, a abertura de um `pull_request`, um horário definido via `schedule`, ou um clique manual via `workflow_dispatch`. Cada tipo de evento carrega consigo um contexto específico — o `pull_request` traz o número do PR, o diff das mudanças e a branch de origem, enquanto o `push` traz o commit SHA e a branch de destino.

Para a TechNova, a configuração mais comum é disparar o CI em dois momentos: `pull_request` para validar antes do merge (ninguém merga código quebrado) e `push` na `main` para garantir que o estado da branch principal está sempre estável. O `workflow_dispatch` é valioso para operações manuais como rerolls e execuções on-demand em ambientes específicos.

---

### Questão 2 — Função da keyword `needs`

**Alternativa correta: c) cria dependência entre jobs — o job só executa se os jobs listados em `needs` passarem.**

Sem `needs`, todos os jobs de um workflow rodam em paralelo em VMs separadas e independentes. Isso seria problemático para um pipeline CI/CD porque os stages têm uma dependência lógica clara: não faz sentido buildar uma imagem Docker de um código que não passou no lint, e não faz sentido fazer push de uma imagem que não passou nos testes. O `needs` cria essa sequência obrigatória.

A ordem `lint → test → build` que configuramos não é arbitrária — é otimizada por custo e velocidade. Lint é o mais rápido (10–15 segundos) e elimina os erros mais triviais. Se falhar, paramos aqui e economizamos o tempo dos testes. Testes são mais demorados mas garantem que a lógica está correta antes do build. Build é o mais lento (pull de imagem base, instalação de dependências, compressão da imagem) — só faz sentido rodar quando tudo antes passou. Com `needs: [lint, test]` no job de build, o GitHub Actions implementa essa lógica automaticamente.

---

### Questão 3 — Onde armazenar credenciais AWS

**Alternativa correta: c) em GitHub Secrets (Settings → Secrets), referenciadas com `${{ secrets.NAME }}`.**

O cenário descrito no TA — AWS keys commitadas acidentalmente, bots que varrem o GitHub em tempo real e contas com faturas de $50.000 num fim de semana — não é hipotético. É um incidente documentado e recorrente. A regra é absoluta: nenhuma credencial vai para o código ou para o YAML do workflow em texto simples.

GitHub Secrets armazena valores com sealed box encryption e os mascara automaticamente nos logs (substituídos por `***`). Mais importante: secrets configurados no repositório não são acessíveis em forks — se alguém criar um fork do repositório da TechNova e abrir um PR malicioso, o workflow dele não terá acesso aos secrets de produção. A sintaxe `${{ secrets.AWS_ACCESS_KEY_ID }}` é resolvida apenas em runtime, dentro do runner, e nunca aparece em nenhum log ou artefato. A combinação de secrets + `.gitignore` para arquivos `.env` é o mínimo que qualquer projeto precisa implementar antes de existir como repositório público.

---

### Questão 4 — Environments com approval gates

**Alternativa correta: b) garantir que deploys para ambientes sensíveis (como produção) requeiram aprovação humana antes de executar.**

Approval gates são o mecanismo que separa Continuous Delivery de Continuous Deployment na prática. Com um environment `production` configurado com required reviewers, o pipeline executa todos os jobs de CI normalmente — lint, testes, build, push para o registry — e então pausa. Um engenheiro sênior (ou o próprio time) recebe uma notificação e pode ver exatamente o que está prestes a ser deployado antes de aprovar. Se algo parece errado — o plan mostra destruição de um recurso crítico, os testes passaram mas o reviewer nota algo suspeito no diff — a aprovação é negada e o deploy não acontece.

Para a TechNova, a configuração mais sensata é: CI roda automaticamente em todo PR (sem aprovação), deploy para staging é automático no merge para main (também sem aprovação), e deploy para produção requer aprovação explícita. Environment secrets específicos para produção (como a chave SSH da EC2 de produção) ficam inacessíveis para qualquer job que não use `environment: production` — o que adiciona uma camada extra de proteção além do approval gate.

---

## Reflexão da Aula

A aula de GitHub Actions marcou a transição de "infraestrutura como código" para "processo como código". Terraform nos permite descrever o que a infraestrutura deve ser — GitHub Actions nos permite descrever o que deve acontecer automaticamente quando o código muda. Os dois juntos fecham o ciclo: infraestrutura provisionada com Terraform, código verificado e deployado com GitHub Actions.

O que mais me impactou foi perceber a escala do problema de segurança que secrets mal gerenciados representam. Não é exagero que bots escaneiam repositórios públicos em tempo real — existem ferramentas específicas para isso, e chaves AWS são um alvo valioso porque permitem criar recursos computacionais para mineração de criptomoedas de forma anônima na conta da vítima. O fato de que o histórico do Git preserva commits deletados torna o problema ainda mais grave: mesmo que você detecte o erro e faça um commit removendo o arquivo com a credencial, ela continuou acessível por um período e ainda está no histórico. A única solução correta é revogar a credencial imediatamente, não "deletar o arquivo e torcer para ninguém ter visto". GitHub Secrets é a resposta certa, e `.gitignore` antes do primeiro commit é o hábito que previne o problema de existir.