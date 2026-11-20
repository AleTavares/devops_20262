# Trabalho em Aula — Aula 10: GitOps + CD Pipeline

**Aluno:** Matheus Mantovani  
**RA:** 1120245  
**Data:** 24/10/2026

---

## Questões de Verificação

### Questão 1 — O que dispara o `terraform apply` no fluxo GitOps

**Alternativa correta: c) merge do Pull Request na branch `main`.**

No fluxo GitOps, o repositório Git é a fonte única de verdade para o estado desejado da infraestrutura. Isso significa que apenas duas operações são relevantes: abrir um PR (que dispara o `terraform plan` como comentário, mostrando o que vai mudar) e fazer merge na `main` (que dispara o `terraform apply`, efetivando a mudança). O merge é a aprovação formal: significa que pelo menos um reviewer leu o plan, entendeu as implicações e concordou com a mudança.

Isso elimina os problemas do fluxo manual descrito no TA: há auditoria completa (cada apply é rastreável ao commit que o triggou), review formal (o PR com o output do plan é o mecanismo de revisão), nenhuma credencial fica em laptops individuais (o GitHub Actions executa o apply com credenciais configuradas como secrets), e o state está sempre protegido pelo locking do DynamoDB. O resultado é que infraestrutura passa pelo mesmo processo que código de aplicação: branch → PR → review → merge → deploy automático.

---

### Questão 2 — Por que OIDC é preferível a access keys permanentes

**Alternativa correta: b) porque OIDC gera credenciais temporárias, eliminando chaves permanentes que podem vazar.**

O problema das access keys permanentes é que elas existem indefinidamente até serem explicitamente revogadas. Uma chave que vaza — seja por commit acidental, breach de secrets, ou ex-funcionário — fica ativa até alguém perceber e revogar. Com OIDC, não há chave para vazar: o GitHub Actions pede um token temporário à AWS no início de cada job, usa-o durante a execução, e ele expira automaticamente ao final. Não existe nenhuma credencial estática armazenada em nenhum lugar.

No contexto do Learner Lab, não podemos usar OIDC porque ele requer criar um IAM OIDC Identity Provider e uma role IAM — operações que o Lab bloqueia. Por isso usamos as credenciais temporárias de sessão como secrets, atualizadas a cada sessão. Isso captura o benefício da temporalidade (as credenciais expiram junto com a sessão do Lab), mas exige renovação manual e não escala para produção. Em um ambiente AWS real, OIDC seria a configuração correta: GitHub Actions assume uma role com as permissões específicas para Terraform, sem nenhuma chave sendo armazenada ou rotacionada manualmente.

---

### Questão 3 — Principal desvantagem da estratégia Recreate

**Alternativa correta: c) Recreate causa downtime inevitável entre parar o container antigo e iniciar o novo.**

A estratégia Recreate é sequencial por natureza: para → remove → pull → inicia. Entre o `docker stop` e o `docker run` da nova versão, a aplicação está simplesmente indisponível. Para um sistema interno como um dashboard de administração ou um ambiente de staging, segundos de indisponibilidade são completamente aceitáveis. Para uma API de produção recebendo tráfego de usuários, qualquer downtime — mesmo de 10 segundos — significa requisições falhando, timeouts e potencialmente erros visíveis ao usuário final.

As estratégias alternativas que resolvem esse problema — Blue-Green e Canary — funcionam mantendo duas versões disponíveis simultaneamente durante a troca. No Blue-Green, o load balancer aponta para o novo ambiente (green) instantaneamente, sem downtime. Se algo der errado, o switch volta para o ambiente antigo (blue) com a mesma velocidade. Para a TechNova no estado atual, Recreate é justificado pela simplicidade: é menos código, menos pontos de falha, e a janela de manutenção é aceitável. À medida que a aplicação cresce e o SLA se torna mais exigente, a migração para Blue-Green é o próximo passo.

---

### Questão 4 — O que acontece se o job de testes falhar no pipeline CD

**Alternativa correta: c) todos os jobs seguintes (build, push, deploy) são cancelados — nada é deployado.**

Essa é a propriedade mais importante de um pipeline CI/CD bem configurado: a falha em qualquer etapa deve bloquear as etapas seguintes. A keyword `needs` implementa isso: o job `build` tem `needs: [lint, test]`, o job `push` tem `needs: build`, o job `deploy` tem `needs: push`. Se `test` falha com exit code 1, o GitHub Actions marca o job como falho e todos os jobs que declaram `needs: test` (direta ou indiretamente) são cancelados automaticamente.

Isso garante que o invariante fundamental do pipeline seja mantido: código que não passou em todos os checks nunca chega a produção. Sem essa garantia, o pipeline seria uma série de etapas independentes que "avisam" sobre problemas mas não os previnem — o que é consideravelmente pior do que não ter pipeline algum, porque cria uma falsa sensação de segurança. No caso da TechNova, isso significa que um teste falhando às 3 da manhã no pipeline de CI não vai resultar num deploy automático de código quebrado em produção enquanto ninguém está olhando.

---

## Reflexão da Aula

A aula de GitOps + CD Pipeline foi a convergência de tudo que aprendemos no Módulo 3. As peças se encaixaram: o GitHub Actions que configuramos na Aula 08 para CI agora se estende até o deploy; a imagem que publicamos no ECR na Aula 09 é agora puxada pelo servidor de produção; e a infraestrutura EC2 que provisionamos nas aulas 04 e 05 passa a ser gerenciada via Pull Requests em vez de comandos locais.

O que me ficou mais claro com GitOps é a mudança filosófica que ele representa. Antes, infraestrutura era algo que "alguém fez" — talvez em 2024, talvez com uma versão diferente do Terraform, talvez com credenciais que ninguém sabe mais quem tem. Com GitOps, infraestrutura é algo que está descrito no repositório, com cada mudança rastreável a um PR específico, com o nome do reviewer que aprovou, com o output do `terraform plan` que mostrava exatamente o que ia mudar. Essa rastreabilidade não é apenas boa prática de segurança — é o que torna possível operar um sistema com confiança ao longo do tempo, independente de quem está na equipe hoje ou daqui a dois anos.