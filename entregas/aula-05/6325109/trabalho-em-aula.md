# Trabalho em Aula — Aula 05: RDS e Remote State

**Aluno:** Carina Gonçalves dos Santos Dalpino
**RA:** 6325109
**Data:** 03/09/2026

---

## Verificação do Trabalho Anterior (TA)

### Questão 1 — Vantagem do RDS
**Resposta: c) RDS gerencia patches, backups e failover automaticamente**

O Amazon RDS abstrai toda a administração do banco de dados: aplica patches de segurança, realiza backups diários automáticos com retenção configurável e oferece failover automático com Multi-AZ. Ao contrário de instalar PostgreSQL manualmente num EC2, o RDS não exige um DBA dedicado para manter o servidor do banco operacional e seguro.

### Questão 2 — DB Subnet Group
**Resposta: c) Para garantir resiliência e possibilitar Multi-AZ no futuro**

A AWS exige subnets em pelo menos 2 AZs no DB Subnet Group porque: (1) se uma AZ falhar, há infraestrutura disponível para recuperação; (2) ao ativar Multi-AZ, o standby precisa de uma AZ diferente do primário; (3) durante manutenções, a AWS pode precisar mover o banco entre AZs.

### Questão 3 — Remote State
**Resposta: b) Porque permite que todos os membros da equipe compartilhem o mesmo state e colaborem**

Com state local, apenas quem tem o arquivo `terraform.tfstate` consegue executar Terraform — o time fica bloqueado. O state remoto no S3 é centralizado, versionado, encriptado e acessível por toda a equipe com as permissões IAM corretas.

### Questão 4 — DynamoDB Locking
**Resposta: c) Impedir que duas execuções simultâneas de Terraform modifiquem o state ao mesmo tempo**

Quando dois desenvolvedores rodam `terraform apply` simultaneamente sem locking, ambos lêem o mesmo state, calculam mudanças independentemente e escrevem versões conflitantes — corrompendo o state. A tabela DynamoDB cria um registro de lock durante o apply e o remove ao terminar; quem chegar segundo recebe erro e é bloqueado até o lock ser liberado.

---

## Discussão em Grupo — Incidentes da TechNova

### Incidente 1: "Dados sumindo" — API com dados em memória

**Problema identificado:** A API armazenava pedidos em arrays JavaScript na memória RAM. Qualquer restart do EC2 — por manutenção, deploy ou falha — apagava todos os dados.

**Causa raiz:** Ausência de camada de persistência. A arquitetura tratava o EC2 como stateful quando deveria ser stateless.

**Solução:** Separar a camada de dados em um banco externo (RDS), que é independente do ciclo de vida das instâncias EC2. O EC2 pode ser terminado, recriado ou escalado horizontalmente sem perder dados — eles vivem no RDS.

**Lição:** Instâncias de computação devem ser tratadas como gado (descartáveis), não como animais de estimação (únicos e insubstituíveis).

### Incidente 2: "Laptop roubado" — State local perdido

**Problema identificado:** Rafael tinha o único `terraform.tfstate` no laptop. Com ele roubado, o Terraform perdeu o mapeamento entre o código HCL e os recursos reais na AWS — ficou "cego". Resultado: `terraform plan` queria recriar tudo, `terraform destroy` não sabia o que destruir, e recursos órfãos continuaram gerando custo.

**Causa raiz:** Ponto único de falha. O state não tinha backup, versionamento nem controle de acesso.

**Solução:** Backend S3 com:
- **Centralização:** state acessível a toda a equipe via IAM
- **Versionamento:** histórico completo, possibilidade de rollback
- **Encriptação:** senhas do RDS protegidas no estado
- **Locking via DynamoDB:** sem corrupção por writes simultâneos
- **Block Public Access:** bucket nunca exposto à internet

**Lição:** O `terraform.tfstate` é tão crítico quanto o próprio código. Merece os mesmos cuidados: backup, versionamento e controle de acesso.

---

## Reflexão — Spec-Driven para Remote State (Lab 2)

### O que o Kiro acertou de primeira?
- Estrutura de arquivos separados por responsabilidade (s3.tf, dynamodb.tf, outputs.tf)
- Configuração correta do provider e versões
- Uso de `random_id` para sufixo único no nome do bucket
- Outputs com bucket name, ARN e table name
- Tags em todos os recursos

### O que precisou de correção?
- Verificar se o `billing_mode = "PAY_PER_REQUEST"` foi gerado corretamente na DynamoDB (às vezes gera `PROVISIONED` por padrão)
- Confirmar que os 4 campos do `aws_s3_bucket_public_access_block` estavam todos como `true`

### Comparação Spec-Driven vs Manual

| Aspecto | Lab 1 — Manual (RDS) | Lab 2 — Spec-Driven (Remote State) |
|---------|----------------------|-------------------------------------|
| Tempo para ter o código | ~40 min seguindo roteiro | ~10 min com Kiro |
| Erros de sintaxe | Alguns (typos no HCL) | Praticamente nenhum |
| Entendimento do código | Alto — escrevi linha a linha | Médio — precisei revisar com atenção |
| Precisou corrigir? | Sim, alguns detalhes | Sim, 1-2 configurações de segurança |
| Abordagem preferida | Para aprender conceitos | Para produtividade no dia a dia |

### Quando usar cada abordagem?
- **Spec-Driven:** infraestrutura nova do zero, quando já se conhece o conceito e quer velocidade
- **Manual:** aprendizado de um recurso novo, debugging, ajustes finos em infraestrutura existente
- **Nunca:** aceitar código gerado sem validar — você é responsável pelo que está na AWS
