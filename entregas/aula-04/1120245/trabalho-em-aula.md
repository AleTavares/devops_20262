# Trabalho em Aula — Aula 04: VPC + EC2

**Aluno:** Matheus Mantovani  
**RA:** 1120245  
**Data:** 25/08/2026

---

## Questões de Verificação

### Questão 1 — Por que não usar a VPC padrão

**Alternativa correta: c) a VPC padrão não oferece isolamento adequado — todos os recursos ficam expostos na mesma rede sem segmentação entre público e privado.**

A VPC padrão existe para facilitar testes rápidos e reduzir a fricção inicial na AWS, mas ela é inadequada para qualquer carga de trabalho séria por uma razão fundamental: ausência de segmentação. Quando colocamos a API da TechNova e o banco de dados PostgreSQL na mesma VPC padrão sem subnets privadas, qualquer recurso criado nela pode potencialmente se comunicar diretamente com qualquer outro — incluindo a internet. Um atacante que consiga explorar uma vulnerabilidade na API Node.js (que está exposta na web) terá caminho aberto até o banco de dados, pois não há barreira de rede entre eles.

Outros problemas concretos: o CIDR da VPC padrão é fixo em `172.31.0.0/16`, o que impede customizações de endereçamento para redes corporativas ou conexões VPN. Não há separação entre o que deve ser público (a API, que precisa responder a requisições da internet) e o que deve ser privado (o banco de dados, que nunca deveria ser acessível de fora). Uma VPC customizada nos permite criar subnets públicas para a camada de aplicação e subnets privadas para a camada de dados, aplicando o princípio de defesa em profundidade desde o nível de rede.

---

### Questão 2 — Diferença entre subnet pública e subnet privada

**Alternativa correta: c) a subnet pública tem uma rota para o Internet Gateway na sua Route Table, permitindo comunicação com a internet.**

A diferença entre os dois tipos de subnet não é de hardware nem de tamanho — é puramente de roteamento. Uma subnet pública possui, em sua Route Table, uma regra `0.0.0.0/0 → igw-xxxxx`, que direciona qualquer tráfego destinado à internet para o Internet Gateway. Uma subnet privada não tem essa rota, então recursos nela só conseguem se comunicar dentro do espaço CIDR da própria VPC (`10.0.0.0/16 → local`).

Na arquitetura da TechNova, isso se traduz diretamente em uma decisão de segurança: a instância EC2 com a API Node.js fica na subnet pública (`10.0.1.0/24`) porque precisa receber requisições de qualquer lugar da internet na porta 3000. O banco de dados PostgreSQL fica na subnet privada (`10.0.2.0/24`) porque deve ser acessível apenas pela própria API — nunca diretamente da internet. Mesmo que alguém descubra o endereço IP do banco, não há rota de rede para chegar até ele a partir da internet pública.

---

### Questão 3 — Security Groups stateful

**Alternativa correta: b) se uma regra permite tráfego de entrada em uma porta, a resposta de saída é automaticamente permitida sem necessidade de regra explícita.**

"Stateful" significa que o Security Group acompanha o estado das conexões TCP. Quando uma requisição HTTP chega na porta 3000 da instância EC2 (porque existe uma regra de ingress `0.0.0.0/0 → TCP:3000`), o SG registra internamente que existe uma conexão ativa. Quando a aplicação responde, o tráfego de volta é reconhecido como parte dessa conexão estabelecida e é automaticamente permitido — mesmo que não exista nenhuma regra de egress explícita para aquela porta específica.

Isso contrasta com as NACLs (Network ACLs), que são stateless: você precisa criar regras explícitas tanto para o tráfego de entrada quanto para o de resposta (incluindo as portas efêmeras 1024-65535 que o cliente usa). A natureza stateful dos Security Groups simplifica muito a configuração — para permitir que a API seja acessada na porta 3000, basta uma regra de ingress. A conversa inteira (requisição + resposta) flui sem precisar declarar o retorno separadamente.

---

### Questão 4 — Função do User Data

**Alternativa correta: c) executar um script automaticamente no primeiro boot da instância, permitindo instalar software e configurar a aplicação sem intervenção manual.**

User Data é o mecanismo de bootstrapping do EC2: um script shell passado na criação da instância que é executado automaticamente uma única vez, durante o primeiro boot, com privilégios de root. Ele é a peça que fecha o ciclo de automação — sem ele, seria necessário fazer SSH na máquina após criá-la, instalar Node.js, clonar o repositório e configurar o serviço manualmente. Qualquer passo manual nesse processo é uma oportunidade de erro humano e quebra a reprodutibilidade da infraestrutura.

Com User Data, o Terraform provisiona a instância e injeta o script que instala as dependências (`curl`, `dnf`, Node.js via NodeSource), clona o repositório da API, executa `npm install` e inicia o servidor. O resultado é que, minutos após o `terraform apply`, a API já está respondendo na porta 3000 sem nenhuma interação manual. Os logs de execução ficam disponíveis em `/var/log/cloud-init-output.log`, o que facilita o debugging quando algo dá errado no processo de inicialização.

---

## Reflexão da Aula

A aula de VPC + EC2 foi o ponto de virada do curso para mim, porque foi a primeira vez que a infraestrutura da TechNova ganhou forma concreta na nuvem — saímos de conceitos de IAM e policies para uma aplicação real respondendo a requisições HTTP. O que mais ficou foi entender que segurança de rede não é uma camada separada adicionada depois: ela é o projeto. A decisão de colocar a API na subnet pública e o banco na privada não é uma "configuração de segurança" — é a própria arquitetura. Sem essa separação, toda a proteção do Security Group que restringe a porta 5432 perde o sentido, porque um atacante com acesso à instância EC2 estaria na mesma rede que o banco.

O User Data me fez perceber também que infraestrutura e aplicação precisam ser tratadas como um sistema único. Antes dessa aula, eu pensava em "subir um servidor" e "configurar a aplicação" como etapas separadas. Com Terraform + User Data, o `terraform apply` entrega uma instância com a aplicação já rodando — o estado final desejado é descrito no código e materializado de uma vez só. Isso é o que torna a infraestrutura reproduzível: posso destruir tudo com `terraform destroy` e recriar em minutos com o mesmo estado.