# Trabalho em Aula — Aula 03: Terraform e Segurança AWS

**Aluno:** [FERNANDA TAVARES]  
**RA:** 4025109  
**Data:** 03/09/2026

## Parte 1 — Análise de Riscos: Infraestrutura Manual

### Riscos e soluções com Terraform

| # | Risco (infraestrutura manual) | Como Terraform resolve |
|---|-------------------------------|------------------------|
| 1 | A infraestrutura fica sem documentação confiável. Se um membro da equipe sair, ninguém sabe exatamente quais recursos, configurações e dependências foram criados. | A infraestrutura é descrita como código, versionada no Git e revisada por pull requests. O histórico mostra quem alterou cada recurso e por quê. |
| 2 | É difícil criar um ambiente de staging idêntico ao de produção, causando diferenças de configuração e problemas que só aparecem em produção. | Módulos e variáveis permitem reutilizar a mesma configuração em ambientes diferentes, mantendo os recursos padronizados. |
| 3 | Uma pessoa pode apagar ou alterar recursos importantes por engano, como aconteceu com o bucket, causando indisponibilidade ou perda de dados. | O `plan` mostra as mudanças antes da aplicação, e o fluxo de revisão reduz alterações acidentais. Recursos críticos também podem usar proteções como `prevent_destroy` e versionamento do estado. |
| 4 | Durante uma auditoria, é difícil comprovar quais alterações foram feitas, quando ocorreram e qual era a configuração anterior. | O código versionado, o histórico de commits, os planos e o estado remoto fornecem rastreabilidade e facilitam auditoria e compliance. |
| 5 | Quando algo para de funcionar fora do horário comercial, a equipe perde tempo tentando reconstruir manualmente o ambiente e corrigir configurações inconsistentes. | O código permite recriar ou corrigir a infraestrutura de forma repetível. Pipelines podem executar `plan` e `apply` com aprovação e registrar os resultados. |
| 6 | Com o crescimento da equipe, várias pessoas podem fazer alterações conflitantes ou usar permissões excessivas no Console. | O Terraform pode ser executado por pipeline com controle de acesso, revisão e state remoto com locking, reduzindo mudanças concorrentes e não autorizadas. |

## Parte 2 — Auditoria de Segurança: Design de IAM

### Estrutura IAM proposta

O usuário root deve ser usado apenas para tarefas excepcionais de configuração da conta, com MFA habilitado. Cada pessoa deve usar um usuário individual, também com MFA, sem compartilhar credenciais.

```text
AWS Account Root (NUNCA usar diretamente)
│
├── Group: Billing-Readers
│   ├── Users: Carlos Mendes
│   └── Policy: TechNovaBillingReadOnly
│       (ações: aws-portal:ViewBilling, ce:Describe*, ce:Get*, ce:List*)
│
├── Group: Developers-S3-EC2-Read
│   ├── Users: Juliana Santos
│   └── Policy: TechNovaDeveloperAccess
│       (ações: s3:GetObject, s3:PutObject, s3:DeleteObject apenas no bucket da aplicação;
│        ec2:Describe*)
│
├── Group: Platform-Engineers
│   ├── Users: Rafael Oliveira
│   └── Policies: TechNovaPlatformAccess e TechNovaIAMReadOnly
│       (ações de gerenciamento necessárias de EC2, S3 e VPC;
│        iam:Get*, iam:List*, iam:Simulate* para leitura de IAM)
│
├── Group: S3-ReadOnly
│   ├── Users: Lucas
│   └── Policy: TechNovaAppDataReadOnly
│       (ações: s3:ListBucket e s3:GetObject apenas no bucket permitido)
│
└── Role: TechNovaApiRole
		├── Trust Policy: EC2 pode assumir a role por meio de ec2.amazonaws.com
		└── Permissions: s3:ListBucket no bucket technova-app-data e
				s3:GetObject, s3:PutObject e s3:DeleteObject nos objetos desse bucket
```

#### Trust policy da role da API

```json
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"Service": "ec2.amazonaws.com"
			},
			"Action": "sts:AssumeRole"
		}
	]
}
```

A role seria associada à instância EC2 por um instance profile. Assim, a aplicação obtém credenciais temporárias e não precisa armazenar access keys no código ou em arquivos da máquina.

#### Observações sobre as policies

- As policies devem restringir recursos por ARN, região e, quando possível, prefixo de objetos.
- Juliana deve ter leitura e escrita no S3, mas não precisa administrar buckets, IAM ou VPC.
- Rafael precisa administrar os recursos de plataforma, mas sua leitura de IAM não deve permitir criar usuários, alterar policies ou assumir qualquer role.
- Lucas deve somente listar o bucket e ler objetos, sem `PutObject`, `DeleteObject` ou alterações de configuração.
- A API deve acessar somente `technova-app-data`, sem permissões gerais para todos os buckets da conta.

### Violações de menor privilégio com Managed Policies

1. Se Juliana recebesse `AmazonS3FullAccess`, poderia criar ou excluir buckets, alterar políticas de acesso e ler ou apagar dados de qualquer bucket da conta, embora precisasse apenas ler e escrever objetos no bucket da aplicação.
2. Se Lucas recebesse `AmazonS3ReadOnlyAccess`, teria leitura de todos os buckets e objetos permitidos na conta, em vez de visualizar somente o bucket necessário para seu estágio.
3. Se a API recebesse uma policy ampla como `AmazonS3FullAccess`, um comprometimento da instância EC2 permitiria apagar ou exfiltrar dados de outros buckets, quando o serviço deveria acessar apenas `technova-app-data`.

### Exemplo de proteção pelo menor privilégio

Se a credencial temporária da API fosse comprometida, uma policy restrita permitiria limitar o impacto ao bucket `technova-app-data`. A credencial não poderia acessar buckets de backup, billing ou dados de clientes de outros sistemas, reduzindo o alcance de um possível ataque.

## Apresentação

- **Risco mais crítico:** exclusão ou alteração acidental de recursos e dados sem possibilidade de reconstruir rapidamente a configuração.
- **Estrutura IAM proposta:** usuários individuais em grupos por função, policies específicas por recurso e uma role exclusiva para a API da EC2.
- **Exemplo de menor privilégio:** mesmo que a role da API fosse comprometida, ela não teria permissão para acessar outros buckets ou administrar a conta.
