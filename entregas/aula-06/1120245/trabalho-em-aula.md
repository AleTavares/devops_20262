# Trabalho em Aula — Aula 06: Terraform Modules

**Aluno:** Matheus Mantovani  
**RA:** 1120245  
**Data:** 08/09/2026

---

## Questões de Verificação

### Questão 1 — Principal benefício de módulos Terraform

**Alternativa correta: b) módulos permitem reutilizar código e eliminar duplicação (DRY).**

O problema concreto que módulos resolvem é o drift silencioso entre ambientes. Imagine que a TechNova tem ambientes de dev e staging com configurações de VPC quase idênticas. Sem módulos, qualquer mudança — por exemplo, adicionar uma tag de compliance a todas as subnets — precisa ser feita em dois lugares. É quase certo que em algum momento as cópias vão divergir: alguém corrige um bug na VPC de dev e esquece de propagar para staging. Meses depois, ninguém sabe mais qual versão está "certa".

Com módulos, existe uma única definição em `modules/vpc/main.tf`. Os dois ambientes chamam esse mesmo módulo com variáveis diferentes (`environment = "dev"` vs `environment = "staging"`). Quando uma mudança é feita no módulo, ela se propaga automaticamente para todos que o chamam na próxima execução. O princípio DRY aplicado à infraestrutura não é só uma questão de elegância de código — é o que garante que os ambientes permaneçam consistentes ao longo do tempo sem esforço manual.

---

### Questão 2 — Diferença entre count e for_each

**Alternativa correta: c) count indexa por número (0, 1, 2); for_each indexa por chave nomeada.**

A diferença entre `count` e `for_each` só fica clara quando você precisa remover um item do meio de uma lista. Com `count = 3`, o Terraform cria `aws_subnet.public[0]`, `[1]` e `[2]`. Se você remover o item do índice 0 (a primeira subnet), o Terraform renumera: o que era `[1]` vira `[0]`, o que era `[2]` vira `[1]`. O Terraform interpreta isso como "destruir o recurso `[1]` e `[2]` e recriar com novos parâmetros" — o que pode causar destruição e recriação desnecessária de recursos de produção.

Com `for_each`, cada recurso tem uma chave nomeada estável: `aws_subnet.this["public-1a"]`, `["public-1b"]`. Remover `"public-1a"` não afeta os outros recursos — apenas aquele com aquela chave específica é destruído. Para a TechNova, onde subnets têm identidade (pública-AZ-a, privada-AZ-b), `for_each` com um mapa é a escolha natural. `count` é adequado apenas para recursos verdadeiramente intercambiáveis, onde a identidade é apenas um número e a ordem não importa.

---

### Questão 3 — Registry vs módulos locais

**Alternativa correta: b) quando precisa de infraestrutura padrão (VPC, RDS) com muitas opções e em produção.**

Módulos do Terraform Registry como `terraform-aws-modules/vpc/aws` são o resultado de anos de uso em produção por milhares de equipes. Eles já resolveram edge cases que você levaria meses para descobrir: subnets em múltiplas AZs, associação correta de route tables, suporte a NAT Gateway, DNS hostnames, VPC peering. Quando a TechNova precisar de uma VPC de produção, usar esse módulo significa partir de uma base battle-tested em vez de reinventar a roda.

A diferença de quando usar módulos locais é de especificidade: se a necessidade é uma convenção de nomenclatura própria da TechNova, uma política de tags específica do negócio, ou uma combinação de recursos que reflete uma decisão arquitetural interna, um módulo local faz sentido porque esse conhecimento é genuinamente exclusivo da empresa. Para estruturas genéricas — VPC, security groups, RDS — o Registry é o caminho mais seguro e rápido. Uma boa estratégia é usar o módulo do Registry como base e criar um módulo local que o chama com as opções padrão da TechNova, centralizando as convenções internas sem abrir mão da base testada.

---

### Questão 4 — Composição de módulos

**Alternativa correta: c) o output de um módulo é passado como input (variável) para outro módulo.**

A composição de módulos é o que transforma módulos independentes em uma infraestrutura integrada. O módulo VPC cria a rede e expõe `vpc_id` e `subnet_ids` como outputs. O módulo Security Group recebe `vpc_id` como variável para criar suas regras no contexto correto e expõe `sg_id`. O módulo EC2 recebe `subnet_id` e `sg_id` para posicionar e proteger a instância. O Terraform lê esse grafo de dependências e constrói os recursos na ordem correta: VPC primeiro, depois Security Group, depois EC2.

Isso é exatamente como funções se compõem em programação: o retorno de uma função se torna argumento da próxima. Em Terraform, a sintaxe é `module.<nome>.<output>`. Se o módulo de VPC exporta `public_subnet_ids`, qualquer outro módulo pode usá-lo como `subnet_id = module.vpc.public_subnet_ids[0]`. O Terraform resolve automaticamente a ordem de criação — você não precisa declarar a dependência explicitamente, ela é inferida do fato de um módulo consumir o output do outro.

---

## Reflexão da Aula

A aula de módulos foi sobre uma transição de mentalidade: de escrever infraestrutura para escrever abstrações de infraestrutura. Até aqui, cada `resource` era concreto e específico para aquele projeto. Com módulos, começamos a pensar em termos de componentes reutilizáveis — uma "VPC" com suas subnets e route tables encapsulada em um único bloco `module "vpc"` que pode ser chamado múltiplas vezes com parâmetros diferentes.

O que ficou mais claro para mim foi a analogia com funções: variáveis de um módulo são os parâmetros, o `main.tf` é o corpo, e os outputs são o valor de retorno. Essa abstração não é apenas para organização — ela é o que torna possível criar um novo ambiente (produção, staging, DR) com algumas linhas de código em vez de duplicar centenas. No contexto da TechNova crescendo, isso é a diferença entre conseguir provisionar novos ambientes em minutos ou passar dias garantindo que as configurações estão consistentes entre cópias manuais do código.