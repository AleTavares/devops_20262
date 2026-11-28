# Aula 11 — Trabalho Anterior (TA)

## Objetivo

Preparar-se para a Aula 11 através de leitura prévia sobre **Blue/Green Deployments** e **Canary Deployments**. Você vai entender como eliminar downtime completamente e como validar novas versões com segurança antes de expor todos os usuários.

---

## Parte 1 — Blue/Green Deployment

### 1.1 O Problema: Downtime no Deploy Recreate

Na Aula 10, implementamos a estratégia Recreate: parar o container antigo, subir o novo. Funciona, mas causa downtime — segundos (ou minutos) onde a aplicação está indisponível.

Para a TechNova, isso é inaceitável:
- Clientes enterprise perdem pedidos durante o downtime
- Reputação de confiabilidade é prejudicada
- SLA de 99.9% não permite mais que 8.76 horas de downtime por ANO

A solução é manter **duas versões rodando ao mesmo tempo** e redirecionar o tráfego sem interrupção.

### 1.2 O que é Blue/Green Deployment?

Blue/Green é uma estratégia de deploy onde existem dois ambientes de produção idênticos:

- **Blue:** o ambiente que está ATIVO, recebendo tráfego dos usuários
- **Green:** o ambiente que está em STANDBY, pronto para receber a nova versão

O fluxo de deploy:
1. A nova versão é deployada no ambiente **Green** (enquanto Blue continua recebendo tráfego normalmente)
2. Testes são executados no Green para confirmar que está saudável
3. O **load balancer** (ALB) redireciona TODO o tráfego de Blue para Green — instantaneamente
4. Green se torna o novo ambiente ativo; Blue fica em standby

**Resultado:** zero downtime. Os usuários nem percebem que houve um deploy.

### 1.3 O Papel do Application Load Balancer (ALB)

O ALB é o componente central do Blue/Green. Ele é quem decide para onde o tráfego vai.

Componentes do ALB relevantes:
- **Listener:** regra que escuta em uma porta (80 ou 443) e decide para onde enviar
- **Target Group:** grupo de instâncias EC2 que recebem o tráfego
- **Health Check:** verificação periódica se as instâncias estão respondendo

Para Blue/Green, criamos **dois Target Groups** (um Blue, um Green) e o Listener aponta para um deles. O deploy é simplesmente mudar o Listener para apontar para o outro.

### 1.4 Rollback Instantâneo

Se a nova versão (Green) apresentar problemas após o switch:
- Basta mudar o Listener de volta para Blue
- Tempo de rollback: menos de 1 segundo
- Blue nunca foi desligado — está íntegro e pronto

Comparação com Recreate:
- **Recreate rollback:** precisa parar v1.1, fazer pull de v1.0, subir container → 30s a 5min
- **Blue/Green rollback:** muda um ponteiro no ALB → < 1 segundo

### 1.5 Custo do Blue/Green

A principal desvantagem é o custo: você precisa de **infraestrutura dobrada** (duas instâncias EC2 rodando ao mesmo tempo, pelo menos durante o deploy).

Estratégias para minimizar custo:
- Manter a instância standby desligada e ligá-la apenas antes do deploy
- Usar instâncias menores para o standby
- No **AWS Academy Learner Lab**: o ALB e as instâncias EC2 ficam cobertos pelos créditos do Lab (suficiente para rodar 1 ALB continuamente durante as aulas)

### 1.6 Terraform para Blue/Green

A infraestrutura Blue/Green é provisionada via Terraform:
- 1 ALB com 1 Listener
- 2 Target Groups (Blue e Green)
- 2 EC2 instances (ou 1 + Auto Scaling)
- Security Groups para ALB e EC2
- Subnets em pelo menos 2 AZs (requisito do ALB)

O **traffic switch** é feito via AWS CLI ou Terraform (modificando o `default_action` do listener).

---

## Parte 2 — Canary Deployment

### 2.1 A Analogia dos Canários

No século XIX, mineradores de carvão desciam às minas com canários em gaiolas. Os canários são extremamente sensíveis a gases tóxicos — se o canário morresse, os mineradores sabiam que deviam evacuar imediatamente, antes que os gases os atingissem.

Em software, o "canário" é uma **pequena porcentagem do tráfego** que recebe a nova versão primeiro. Se essa pequena fatia apresentar problemas (aumento de erros, latência alta), fazemos rollback antes que o problema afete todos os usuários.

### 2.2 Como Funciona o Canary

Ao invés de migrar 100% do tráfego de uma vez (Blue/Green), o Canary faz uma migração **gradual**:

1. **5% do tráfego** vai para a nova versão → monitorar por 5-10 minutos
2. Se OK, **25% do tráfego** → monitorar por 10-15 minutos
3. Se OK, **50% do tráfego** → monitorar por 15-20 minutos
4. Se OK, **100% do tráfego** → nova versão promovida

Em qualquer etapa, se as métricas indicarem problema → **rollback imediato para 0%**.

### 2.3 Weighted Routing no ALB

O ALB suporta **weighted forward actions**: uma única regra pode encaminhar tráfego para múltiplos Target Groups com pesos diferentes.

Exemplo: `weight=95` para stable, `weight=5` para canary
- De cada 100 requests, ~95 vão para a versão estável e ~5 para a canary
- Os pesos são ajustados conforme o rollout progride

Stickiness (opcional): garante que o mesmo usuário sempre caia no mesmo Target Group durante uma sessão, evitando experiência inconsistente.

### 2.4 Métricas para Decisão de Rollout

Durante cada etapa do canary, observamos:

| Métrica | Significado | Quando preocupar |
|---------|------------|-----------------|
| Error rate (5xx) | % de responses com erro servidor | > 5% (ou 2x do baseline) |
| Latência p99 | Tempo que 99% dos requests completam | > 2x do valor normal |
| CPU/Memory | Consumo de recursos da instância | > 80% |
| Target Health | Instâncias saudáveis no TG | Qualquer unhealthy |

Se qualquer métrica cruzar o threshold definido → rollback automático.

### 2.5 Canary vs Blue/Green: Quando Usar Cada Um

**Use Blue/Green quando:**
- Tem alta confiança no deploy (testes extensivos passaram)
- Precisa de deploy rápido (switch instantâneo)
- App tem baixo tráfego ou é interna
- Hotfix urgente que já foi testado

**Use Canary quando:**
- Mudança é de alto risco (refatoração grande, nova feature)
- App tem muitos usuários (impacto de bug é alto)
- Quer validar com dados reais de produção
- Feature nova que pode ter comportamento inesperado sob carga real

### 2.6 Rollback Automático

O rollback canary é simples: mudar os pesos do ALB de volta para 100% stable e 0% canary.

Pode ser automatizado via:
- Script bash com loop de health check (como no lab)
- GitHub Actions com step condicional
- AWS CloudWatch Alarm que dispara Lambda para modificar os pesos
- Ferramentas como AWS CodeDeploy ou Flagger (Kubernetes)

### 2.7 Stickiness e Experiência do Usuário

Sem stickiness, um mesmo usuário pode alternar entre versões durante uma sessão:
- Request 1 → v1.0 (interface antiga)
- Request 2 → v1.1 (interface nova)
- Request 3 → v1.0 (voltou para antiga)

Isso causa confusão. Com stickiness habilitada:
- ALB usa cookie para "fixar" o usuário em um Target Group
- Duração configurável (5 min, 1 hora, etc.)
- Após expirar, próximo request segue a distribuição por peso normalmente

---

## Questões de Verificação

Responda as questões abaixo para verificar sua compreensão. Traga suas respostas para a discussão em aula.

### Questão 1

No Blue/Green Deployment, o que acontece com o ambiente Blue APÓS o traffic switch para Green?

- a) Blue é imediatamente destruído para economizar custos
- b) Blue continua rodando em standby, pronto para rollback se necessário
- c) Blue recebe 50% do tráfego enquanto Green recebe os outros 50%
- d) Blue é atualizado automaticamente para a mesma versão do Green

### Questão 2

Qual é a principal vantagem do Canary sobre o Blue/Green quando a mudança é de alto risco?

- a) Canary é mais barato porque usa menos instâncias
- b) Canary permite validar a nova versão com tráfego real e limitar o impacto de bugs a uma fração dos usuários
- c) Canary é mais rápido de implementar
- d) Canary não precisa de Load Balancer

### Questão 3

Durante um rollout canary, a taxa de erro da nova versão sobe para 12% na etapa de 25% do tráfego. O threshold configurado é 5%. O que deve acontecer?

- a) Continuar o rollout porque 12% é aceitável na etapa inicial
- b) Pausar o rollout e aguardar a taxa baixar
- c) Rollback imediato: voltar 100% do tráfego para a versão estável
- d) Aumentar o tráfego para 50% para ter mais dados

### Questão 4

Por que o ALB requer subnets em pelo menos 2 Availability Zones (AZs)?

- a) Porque o ALB precisa de exatamente 2 Target Groups
- b) Para garantir alta disponibilidade — se uma AZ falhar, o ALB continua operando na outra
- c) Porque o Blue fica em uma AZ e o Green na outra
- d) Para reduzir custos de data transfer entre AZs

---

## Referências

- [Blue/Green Deployments — Martin Fowler](https://martinfowler.com/bliki/BlueGreenDeployment.html)
- [Canary Releases — Martin Fowler](https://martinfowler.com/bliki/CanaryRelease.html)
- [Application Load Balancer — User Guide (AWS)](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
- [Weighted Target Groups (AWS)](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html#forward-actions)
