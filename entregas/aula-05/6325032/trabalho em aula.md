Trabalho em Aula — Aula 05: RDS e Estado Remoto
Aluno: daniel tavares
RA: 6325032
Data: 12/09/2026

Parte 1 — Análise dos Incidentes
Cenário A: Perda de Dados
1. Por que os dados foram perdidos?

Os dados foram perdidos porque foram armazenados na memória (RAM) ou no sistema de arquivos efêmero da instância EC2 — provavelmente em uma estrutura de dados em processo (ex: array/variável no código da API) ou em um banco de dados local sem volume persistente. Quando a instância EC2 foi reiniciada, todo o estado em memória foi descartado, e os 5 pedidos de teste desapareceram juntos.

2. Outras situações que causariam a mesma perda (mínimo 3):

Crash da aplicação ou do sistema operacional: se o processo da API travar ou o sistema operacional encontrar um erro fatal (kernel panic, OOM killer), todos os dados na memória são perdidos imediatamente.
Encerramento manual ou acidental da instância EC2: rodar aws ec2 terminate-instancesou parar a instância pelo console sem persistência prévia tem o mesmo efeito da reinicialização programada.
Escalonamento automático (Auto Scaling): se um grupo de Auto Scaling substitui uma instância por uma nova (por falha de verificação de integridade, por exemplo), uma nova instância começa com estado zerado.
Deploy de nova aplicação: um redeploy que reinicia o processo da API descartou todos os dados que estavam apenas na memória do processo anterior.
Interrupção de instância Spot: instâncias Spot podem ser interrompidas com apenas 2 minutos de aviso, eliminando qualquer dado não persistido.
3. Por que “não reiniciar o EC2” não é uma solução válida?

Porque as reinicializações são inevitáveis ​​na produção: a AWS realiza manutenções programadas, patches de segurança do sistema operacional, fecha reinicialização, falhas de hardware forçam migrações e eventos como queda de energia ou falha de rede podem romper a instância a qualquer momento. Além disso, essa "solução" não protege contra nenhum dos outros planos listados acima (crash, deploy, escalonamento). Confiar em "nunca reiniciar" significa aceitar que a aplicação não tem confiabilidade ; é uma decisão arquitetônica que transfere o risco para o operador humano em vez de resolver o problema na camada correta.

4. Diferença entre dados de memória e dados persistentes:

Dados em Memória	Dados Persistentes
Onde cada	RAM do processo/servidor	Disco, banco de dados, S3, etc.
Sobrevivem às reinicializações?	Não	Sim
Velocidade de acesso	Muito rápido (nanosegundos)	Mais lenta (milissegundos)
exemplos	Variáveis, cache, sessão em processo	RDS, DynamoDB, EBS, S3
Uso	Dados temporários, cache, computação	Dados de negócio, estado persistente, registros
Em resumo: dados em memória existem apenas enquanto o processo está vivo; os dados persistentes sobrevivem independentemente do ciclo de vida do processo ou da máquina.

Cenário B: Perda do Estado
1. O que acontece se rodarem terraform plansem o estado?

Sem o arquivo terraform.tfstate, o Terraform não tem nenhum mapeamento entre os recursos declarados no código HCL e os recursos reais que existem na AWS. Ele parte do pressuposto de que não existe nada provisionado. Por isso, terraform planvou apresentar um plano para criar todos os recursos do zero — instâncias EC2, Security Groups, VPC, subnets, RDS, etc. — mesmo que eles já existem na conta AWS. O Terraform simplesmente “não enxerga” o que já está lá.

2. Risco de rodar terraform applynessa situação:

Os riscos são graves:

Tentativa de criar recursos duplicados: o Terraform vai tentar criar recursos que já existem, o que pode resultar em erros (ex: conflito de nome) ou, pior, na criação de recursos paralelos e redundantes gerando custos desnecessários.
Conflitos de nomes e IDs únicos: recursos como buckets S3 têm nomes globalmente únicos; tente criar um bucket que já existe resultado em erro ou, se o nome for diferente, em um bucket duplicado.
Perda de dados em produção: se o Terraform decidir recriar um banco de dados RDS (em vez de falhar), os dados existentes são destruídos no processo.
Estado inconsistente: após uma aplicação parcial sem estado original, o novo estado só vai mapear os recursos criados nessa execução, deixando todos os recursos originais órfãos — gerenciados pela AWS mas invisíveis ao Terraform.
Mudanças no Security Group: no cenário do Rafael, uma mudança urgente no Security Group pode abrir ou fechar portas erradas se o Terraform não souber qual é o estado atual das regras.
3. Importação do Terraform como solução de emergência:

Sim, o comando terraform importpermite "adotar" recursos existentes na AWS para dentro de um novo arquivo de estado. O fluxo seria:

# Exemplo: importar uma instância EC2 existente
terraform import aws_instance.api i-0abc123def456789

# Importar um Security Group
terraform import aws_security_group.ec2_sg sg-0123456789abcdef

# Importar um RDS
terraform import aws_db_instance.postgres mydb-identifier
O processo é trabalhoso: é preciso identificar o ID de cada recurso no console da AWS e executar um importseparado para cada um. Após isso, você terraform plandeve mostrar zero diferenças entre o estado e a infraestrutura real - qualquer divergência precisa ser resolvida manualmente no código HCL antes de aplicar qualquer mudança.

4. Como essa situação poderia ter sido evitada:

Remote State no S3: armazena ou terraform.tfstateem um bucket S3 compartilhado pela equipe, não na máquina local de nenhum desenvolvedor. O arquivo fica acessível para todos, independentemente de quem está usando no momento.
Versionamento do bucket S3: ativa o versionamento no bucket protegido contra exclusão acidental e permite rollback do state para uma versão anterior.
Nunca comprometa o estado no Git: o .gitignoredeve incluir *.tfstatee *.tfstate.backup, pois além do risco de perda, o estado pode conter informações sensíveis (senhas, chaves).
Locking com DynamoDB: impede que duas pessoas modifiquem o estado simultaneamente, evitando corrupção.
Parte 2 — Design da Arquitetura
Diagrama Arquitetural (descrição textual)
┌─────────────────────────────────────────────────────────────────────┐
│                        AWS Account                                  │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  VPC: 10.0.0.0/16                                            │   │
│  │                                                              │   │
│  │  ┌──────────────────────┐  ┌──────────────────────────────┐  │   │
│  │  │  us-east-1a          │  │  us-east-1b                  │  │   │
│  │  │                      │  │                              │  │   │
│  │  │ ┌──────────────────┐ │  │                              │  │   │
│  │  │ │ Subnet Pública   │ │  │                              │  │   │
│  │  │ │ 10.0.1.0/24      │ │  │                              │  │   │
│  │  │ │                  │ │  │                              │  │   │
│  │  │ │ ┌──────────────┐ │ │  │                              │  │   │
│  │  │ │ │  EC2 (API)   │ │ │  │                              │  │   │
│  │  │ │ │  SG: 22,3000 │ │ │  │                              │  │   │
│  │  │ │ └──────┬───────┘ │ │  │                              │  │   │
│  │  │ └────────┼─────────┘ │  │                              │  │   │
│  │  │          │ porta 5432│  │                              │  │   │
│  │  │ ┌────────▼─────────┐ │  │ ┌──────────────────────────┐│  │   │
│  │  │ │ Subnet Privada   │ │  │ │ Subnet Privada           ││  │   │
│  │  │ │ 10.0.2.0/24      │ │  │ │ 10.0.3.0/24              ││  │   │
│  │  │ │                  │ │  │ │                          ││  │   │
│  │  │ │ ┌──────────────┐ │ │  │ │ ┌──────────────────────┐││  │   │
│  │  │ │ │ RDS Primary  │ │ │  │ │ │ RDS Standby (AZ req.)│││  │   │
│  │  │ │ │ PostgreSQL   │ │ │  │ │ │ DB Subnet Group      │││  │   │
│  │  │ │ │ SG: 5432     │ │ │  │ │ │ SG: 5432             │││  │   │
│  │  │ │ │ (só do EC2)  │ │ │  │ │ │ (só do EC2)          │││  │   │
│  │  │ │ └──────────────┘ │ │  │ │ └──────────────────────┘││  │   │
│  │  │ └──────────────────┘ │  │ └──────────────────────────┘│  │   │
│  │  └──────────────────────┘  └──────────────────────────────┘  │   │
│  │                │                                              │   │
│  │         ┌──────▼──────┐                                      │   │
│  │         │  Internet   │                                      │   │
│  │         │  Gateway    │                                      │   │
│  └─────────┴──────┬──────┴──────────────────────────────────────┘   │
│                   │                                                  │
│                 Internet                                             │
│                                                                      │
│  ┌─────────────────────┐    ┌─────────────────────────────────────┐  │
│  │  S3 Bucket          │    │  DynamoDB Table                     │  │
│  │  (Remote TF State)  │    │  (State Locking)                    │  │
│  │  fora da VPC        │    │  fora da VPC                        │  │
│  └─────────────────────┘    └─────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
Identificação dos componentes
Componentes acessíveis da internet:

EC2 (API): está na sub-rede pública com rota para o Internet Gateway. As portas 22 (SSH) e 3000 (API HTTP) estão abertas no Security Group para tráfego externo.
Internet Gateway: é o ponto de entrada/saída da VPC para a internet pública.
S3 Bucket e DynamoDB: tecnicamente acessíveis via internet (são serviços gerenciados da AWS fora da VPC), mas o acesso é controlado por políticas IAM, não por grupos de segurança.
Componentes isolados (sem acesso direto da internet):

RDS PostgreSQL: está nas sub-redes privadas, que não têm rota para o Internet Gateway. O Security Group permite conexão na porta 5432 apenas a partir do Security Group do EC2 — nenhum tráfego externo chega ao banco.
Sub-redes privadas (10.0.2.0/24 e 10.0.3.0/24): não possuem tabela de rotas direcionada para o Internet Gateway, portanto são completamente isoladas da internet pública.
Por que o RDS precisa de sub-redes em 2 AZs mesmo sem Multi-AZ ativo?

A AWS exige que um DB Subnet Group contenha sub-redes em pelo menos duas zonas de disponibilidade diferentes . Isso é um requisito obrigatório da API do RDS, independente de o Multi-AZ estar habilitado ou não. A razão é que a AWS precisa de flexibilidade para posicionar (ou reposicionar) uma instância de banco de dados dentro da região — por exemplo, durante uma falha de AZ, uma manutenção ou uma futura ativação de Multi-AZ. Sem esse requisito satisfeito, o próprio Terraform (ou o console da AWS) retorna erro ao tentar criar o RDS.

Parte 3 — Discussão: Conflito Simultâneo
Cenários reais onde conflito de estado ocorreria
CI/CD + desenvolvedor simultâneos: um pipeline de implantação automática (GitHub Actions, GitLab CI) roda terraform applyapós uma fusão na branch main, ao mesmo tempo em que um desenvolvedor aplica uma mudança de emergência manualmente no terminal — ambos partem do mesmo estado e a corrida (race Condition) é obtida sem locking.
Dois engenheiros de infraestrutura sem comunicação: em tempos distribuídos (fusos horários diferentes), Dev A no Brasil começa a trabalhar quando Dev B na Europa ainda não terminou seu apply — sem locking, os dois operam sobre o mesmo estado simultaneamente.
Múltiplos espaços de trabalho compartilhando o estado: em ambientes onde o preparo e a produção incluem configurações e o estado não está devidamente separado, uma mudança no preparo pode contaminar o estado de produção.
Retry automático em pipelines: um pipeline que falhou na metade e foi reexecutado automaticamente pode colidir com um apply ainda em andamento do run anterior que travou mas não liberou o lock.
Impacto de um estado prejudicado
Um estado prejudicado é um dos cenários mais críticos em infraestrutura como código:

Terraform perde o rastreamento de recursos: recursos reais na AWS ficam "órfãos" — existem, geram custos, mas o Terraform não sabe que eles existem e pode tentar recria-los.
Destruição acidental de recursos: se o Terraform interpretar que um recurso "novo" do estado danificado substituiu um existente, pode emitir um destroyseguido de create— apagando um banco de dados de produção, por exemplo.
Deriva silenciosa: mudanças manuais feitas na AWS enquanto o estado está corrompido não são capturadas, levando a divergências crescentes entre o código e a realidade.
Impossibilidade de aplicar alterações: com o estado inconsistente, todo terraform planproduz resultados imprevisíveis, paralisando a equipe até que o estado seja restaurado ou reconstruído manualmente via terraform import.
Custo de recuperação alto: reconstruir o estado de uma infraestrutura complexa terraform importpode levar horas ou dias, dependendo do número de recursos.
Como o locking com DynamoDB resolve o problema
O bloqueio do DynamoDB garante exclusão mútua nas transações escritas no estado: apenas um processo pode adquirir o bloqueio por vez. O Terraform registra um item na tabela DynamoDB com metadados do lock (quem está executando, desde quando, qual operação). Qualquer outro terraform applyque tente rodar simultaneamente detecta o bloqueio existente e aguarda ou falha com uma mensagem clara — nunca sobrescreve um estado em uso. Quando a operação termina (com sucesso ou erro), o bloqueio é liberado e o próximo processo pode exigir o estado atualizado . Isso transforma uma operação concorrente perigosa em uma fila serializada e segura.