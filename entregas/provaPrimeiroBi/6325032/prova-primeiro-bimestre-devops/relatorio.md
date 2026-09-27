# Relatório do Processo — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Daniel de Oliveira Tavares Junior
**RA:** 6325032
**Data:** [preencher no dia da prova]
**Ferramenta de IA utilizada:** Claude (Anthropic)

> ⚠️ Este arquivo é um ESQUELETO. Os parágrafos abaixo trazem a estrutura e os
> pontos técnicos corretos, mas o enunciado pede uma resposta dissertiva
> baseada na SUA experiência real. Antes de entregar, reescreva em primeira
> pessoa contando o que você de fato fez, viu e decidiu — inclusive onde
> travou, o que teve que corrigir, e o que a IA sugeriu errado (é isso que a
> Questão 4 avalia).

## Questão 1 — A Jornada Completa (Aulas 01 a 07)

A ordem seguida foi: primeiro o repositório e a aplicação (Aula 01 — Git),
depois a containerização da API sozinha (Aula 01 — Docker), em seguida o
Docker Compose subindo API + PostgreSQL juntos (Aula 02), e só então a
infraestrutura na AWS: rede (Aula 04 — VPC), controle de acesso (Aula 03 —
IAM/LabRole e Security Groups), o banco gerenciado (Aula 05 — RDS) e por fim
a modularização com estado remoto (Aula 05/06 — S3+DynamoDB, módulos).
Essa ordem existe porque cada camada depende da anterior: não dá para testar
a conexão da API com um banco antes de a API existir, não dá para provisionar
EC2/RDS antes de a VPC e os Security Groups existirem, e não dá para
modularizar algo que ainda não se sabe se funciona monolítico.

[Descreva aqui, com suas palavras, onde cada aula (01 a 07) apareceu
concretamente na sua solução — cite arquivos/decisões específicas.]

## Questão 2 — O Processo com IA como Copiloto

Usei o Claude como copiloto: descrevi o problema (rotas CRUD, banco Postgres,
Docker Compose com healthcheck, módulos Terraform vpc/security-group/ec2/rds
com LabRole/LabInstanceProfile) e revisei cada arquivo gerado antes de aceitar.
A IA foi eficiente para gerar o boilerplate repetitivo (rotas Express, blocos
HCL dos módulos, Dockerfile multi-stage) e para lembrar detalhes fáceis de
esquecer (usuário não-root no Dockerfile, `storage_encrypted` no RDS,
`security_group_rule` separada para evitar dependência circular entre SGs).

[Descreva os prompts principais que você realmente usou, o que precisou
corrigir manualmente (nomes de recursos, versão do provider, região,
tamanho de instância) e onde a IA "alucinou" algo que você teve que checar
na documentação oficial.]

## Questão 3 — Infraestrutura, Segurança e Learner Lab

A EC2 fica na sub-rede pública porque precisa ser alcançável pela internet
(a API dos clientes). O RDS fica na sub-rede privada porque não deve ser
acessível diretamente da internet — só a aplicação (rodando na EC2) precisa
falar com ele, e isso é garantido tecnicamente pelo Security Group do RDS,
que só libera a porta 5432 a partir do Security Group da EC2 (não de um IP
ou CIDR). Isso é defesa em profundidade: mesmo que a chave SSH da EC2 vaze,
quem não estiver "dentro" do SG da EC2 não alcança o banco.

O Learner Lab não permite criar usuários, grupos ou papéis IAM — por isso a
EC2 usa o `LabInstanceProfile` já existente (referenciado pelo nome, não
criado pelo Terraform) em vez de um instance profile próprio. As credenciais
usadas pelo Terraform (Access Key, Secret Key e Session Token) são
temporárias e expiram quando a sessão do Lab reinicia — se o `terraform
plan`/`apply` falhar com erro de autenticação, o mais provável é a credencial
expirada, e a correção é reiniciar o Lab e atualizar `~/.aws/credentials`.

[Se quiser, inclua aqui um diagrama simples da arquitetura: VPC → 2 AZs →
sub-rede pública (EC2) / sub-rede privada (RDS) → Security Groups.]

## Questão 4 — Validação e Responsabilidade

Antes de rodar `terraform apply`, o checklist que usei foi: (1) `terraform
validate` sem erros, (2) ler o `terraform plan` inteiro e conferir que só
os recursos esperados aparecem (nenhum `aws_iam_role` ou `aws_iam_user`, que
o Lab bloqueia), (3) confirmar que o RDS está com `publicly_accessible =
false` e `storage_encrypted = true`, (4) confirmar que o Security Group do
RDS não libera `0.0.0.0/0` na porta 5432, e (5) confirmar a região
`us-east-1` em todos os providers.

Se eu tivesse aceitado o código gerado pela IA sem revisar, o risco mais
provável seria um Security Group aberto demais (a IA, por padrão, tende a
gerar `0.0.0.0/0` em regras de entrada quando não instruída com cuidado) ou
uma tentativa de criar recursos IAM que o Lab rejeitaria com erro de
permissão — nesse caso o `apply` falharia no meio, deixando recursos parciais
provisionados (e consumindo crédito) até um `terraform destroy` de limpeza.

[Descreva aqui, com um exemplo real seu, algo que a IA gerou e que você
corrigiu ou rejeitou depois de revisar.]
