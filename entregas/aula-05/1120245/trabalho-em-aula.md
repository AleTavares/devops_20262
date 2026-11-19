# Trabalho em Aula — Aula 05: RDS + Remote State

**Aluno:** Matheus Mantovani  
**RA:** 1120245  
**Data:** 01/09/2026

---

## Questões de Verificação

### Questão 1 — Vantagem do RDS

**Alternativa correta: c) RDS gerencia patches, backups e failover automaticamente.**

A diferença fundamental entre instalar PostgreSQL num EC2 manualmente e usar o Amazon RDS não está em qual banco você usa — é sobre quem assume a responsabilidade operacional. Com PostgreSQL no EC2, o time da TechNova precisa se preocupar com tudo: aplicar patches de segurança do SO e do próprio PostgreSQL, configurar e testar scripts de backup (e validar periodicamente que eles funcionam), implementar monitoramento com alertas, e construir o mecanismo de failover se o servidor cair. Essa carga operacional cresce com a equipe e com o tempo — e frequentemente é negligenciada até que aconteça um incidente.

Com RDS, a AWS assume o "undifferentiated heavy lifting": patches do sistema operacional são aplicados automaticamente em janelas configuráveis; backups diários com Point-in-Time Recovery ficam disponíveis sem nenhuma configuração adicional; o CloudWatch está integrado por padrão. Para a TechNova, que é uma startup focada no produto, essa troca faz todo sentido: o time foca no schema, nas queries e na lógica de negócio, não em administração de banco de dados. O único trade-off é abrir mão do acesso SSH ao servidor — o que, na prática, raramente faz falta em cenários de aplicação web.

---

### Questão 2 — DB Subnet Group com 2 AZs

**Alternativa correta: c) para garantir resiliência e possibilitar Multi-AZ no futuro.**

O DB Subnet Group precisa de subnets em pelo menos duas Availability Zones mesmo quando `multi_az = false` porque esse requisito não é sobre o uso imediato do Multi-AZ — é sobre a capacidade de a AWS gerenciar e manter o banco com segurança ao longo do tempo. Se o RDS estiver em apenas uma AZ e aquela AZ enfrentar um problema de hardware ou manutenção planejada, a AWS pode precisar mover o banco para outra AZ. Sem um subnet group com múltiplas AZs, essa operação seria impossível.

Do ponto de vista prático na TechNova: criamos `private_subnet_1` em `us-east-1a` e `private_subnet_2` em `us-east-1b`. O RDS instancia o banco primário em `us-east-1a`, mas sabe que pode usar `us-east-1b` se necessário. Quando o time decidir ativar Multi-AZ no futuro para aumentar a disponibilidade, não haverá nenhuma mudança de infraestrutura necessária — a subnet da réplica standby já existe e está configurada. Essa é uma das situações em que o custo zero de preparar a infraestrutura corretamente desde o início evita um trabalho significativo (e um downtime de manutenção) no futuro.

---

### Questão 3 — Remote State crítico para equipes

**Alternativa correta: b) porque permite que todos os membros da equipe compartilhem o mesmo state e colaborem.**

O cenário do laptop roubado ilustra com clareza um problema que vai muito além do roubo físico: o `terraform.tfstate` armazenado localmente cria um **single point of failure humano**. Apenas quem tem o arquivo pode executar qualquer operação de Terraform — plan, apply ou destroy. Para uma equipe de três ou quatro pessoas na TechNova, isso significa que se a pessoa que provisionou a infraestrutura estiver de férias, doente ou sair da empresa, ninguém mais consegue gerenciar a infraestrutura com Terraform. Pior: um `terraform plan` executado por outro membro criaria tudo do zero, pois não há state para comparar com o que existe na AWS.

O state remoto no S3 resolve isso tornando o mapeamento entre código e recursos AWS um objeto compartilhado e durável. Qualquer membro da equipe pode executar `terraform init` e imediatamente ter acesso ao mesmo estado da infraestrutura. Além disso, com versionamento habilitado no bucket S3, é possível inspecionar o state de qualquer momento anterior — útil para auditorias e para entender o que mudou entre aplicações.

---

### Questão 4 — Propósito do DynamoDB locking

**Alternativa correta: c) impedir que duas execuções simultâneas de Terraform modifiquem o state ao mesmo tempo.**

O problema de concorrência com Terraform é sutil mas devastador: se Rafael executa `terraform apply` para adicionar um security group ao mesmo tempo que Juliana executa outro `terraform apply` para modificar uma regra de rota, as duas execuções leem o mesmo state, calculam seus planos independentemente e tentam escrever versões diferentes do state de volta no S3. O resultado é um state corrompido — partes da infraestrutura não representadas corretamente, recursos "desaparecidos" do state sem serem destruídos na AWS, dependências quebradas.

O DynamoDB resolve isso como um distributed lock: quando o Terraform inicia, ele tenta criar um registro na tabela com `LockID` = caminho do state. Se outro processo já criou esse registro (está rodando), o Terraform recebe um erro explícito com informações de quem tem o lock — nome do operador, timestamp, operação em andamento. O lock é liberado ao fim da execução, independentemente de sucesso ou falha. É exatamente o mesmo mecanismo de um semáforo em sistemas distribuídos: garante que apenas um escritor acesse o recurso crítico por vez. Para a TechNova com remote state no S3, o par S3 + DynamoDB não é opcional — é o que torna o state remoto seguro para uso em equipe.

---

## Reflexão da Aula

A aula de RDS + Remote State conectou dois problemas que parecem distintos mas têm a mesma raiz: o que acontece quando dados críticos ficam em um lugar frágil e irrecuperável. Dados em memória no EC2 somem com um restart — assim como o state do Terraform some quando o laptop é roubado ou formatado. A solução em ambos os casos é externalizar o dado crítico para um armazenamento durável, gerenciado e compartilhado.

O que mais me impactou foi descobrir que o `terraform.tfstate` contém senhas em texto simples, incluindo a senha do RDS. Isso muda completamente o perfil de risco de um state local: não é apenas uma questão de acesso ao Terraform, é uma questão de segurança de credenciais. Um arquivo de estado local que vaza junto com um laptop comprometido expõe não só a topologia de toda a infraestrutura, mas também as credenciais para acessá-la. O `encrypt = true` no backend S3 e o controle de acesso por IAM são proteções essenciais, não opcionais. Essa aula reforçou que infraestrutura segura não é só sobre o que você builda — é sobre como você gerencia o conhecimento do que você buildou.