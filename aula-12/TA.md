# TA — Trabalho Anterior | Aula 12

## Instruções

Este material deve ser estudado **ANTES** da aula. A leitura completa é obrigatória e será avaliada através das questões ao final.

---

## Conteúdo Teórico

### 1. Rollback: Por Que Todo Deploy Precisa de Um Plano B

Em produção, a pergunta não é "SE algo vai dar errado", mas "QUANDO algo vai dar errado". Um rollback é o processo de reverter um sistema para um estado anterior funcional após um deploy problemático.

**Conceitos fundamentais:**

- **MTTR (Mean Time To Recovery):** Tempo médio entre a detecção de um problema e a recuperação completa do sistema. Empresas de alta performance têm MTTR < 1 hora; elite performers < 15 minutos.
- **TTD (Time To Detect):** Tempo até perceber que algo está errado. Automação reduz de "alguém reclama" (minutos/horas) para "alerta automático" (segundos).
- **TTR (Time To Recover):** Tempo para executar a correção. Rollback manual = minutos; automático = segundos.

**A regra de ouro:** Todo deploy deve ser reversível em menos tempo do que levou para deployar.

### 2. Estratégias de Rollback por Tipo de Deploy

Cada estratégia de deploy define como o rollback funciona:

**Recreate (Stop → Start):**
- Rollback: para container novo, sobe imagem anterior
- Downtime: durante todo o processo
- Quando usar: apps internas, ambientes não-críticos

**Blue-Green:**
- Rollback: muda o load balancer de volta para o ambiente anterior (que ainda está rodando)
- Downtime: zero (o ambiente antigo nunca foi desligado)
- Quando usar: apps com SLA rigoroso, quando o custo de 2 ambientes é aceitável

**Canary:**
- Rollback: remove as instâncias canary, restaura 100% do tráfego para a versão estável
- Downtime: zero (apenas a porcentagem canary foi afetada)
- Quando usar: sistemas de grande escala onde o blast radius deve ser minimizado

### 3. Migrações de Banco de Dados Reversíveis

O maior desafio do rollback é o banco de dados. Código é stateless (troca de container), mas dados são stateful. Se uma migração altera o schema de forma incompatível com a versão anterior, o rollback de código vai quebrar.

**Padrão Expand-Contract:**

1. **Expand:** Adiciona novos campos/tabelas SEM remover os antigos. Ambas as versões funcionam.
2. **Migrate:** Copia dados do formato antigo para o novo. App escreve em ambos.
3. **Contract:** Remove campos antigos SOMENTE quando a versão antiga não é mais necessária.

**Regras para migrações seguras:**
- Nunca renomear colunas diretamente — crie nova, copie dados, depois remova a antiga
- Nunca remover colunas no mesmo deploy que muda o código
- Toda migração deve ter um script de rollback testado
- Use transações quando possível para garantir atomicidade

### 4. Feature Flags: Controle Sem Redeploy

Feature flags (ou feature toggles) são condicionais no código que permitem ativar ou desativar funcionalidades em runtime. Quando uma feature nova causa problemas, basta desligar a flag — sem redeploy, sem rollback de container.

**Tipos de feature flags:**

| Tipo | Duração | Exemplo |
|------|---------|---------|
| Release flag | Dias/semanas | Nova feature em desenvolvimento |
| Ops flag | Permanente | Kill switch para emergências |
| Experiment flag | Dias | A/B testing |
| Permission flag | Permanente | Funcionalidade premium |

**Implementação básica com variáveis de ambiente:**
```javascript
// Simples e eficiente para startups
const isNewCheckoutEnabled = process.env.FF_NEW_CHECKOUT === 'true';

app.post('/checkout', (req, res) => {
  if (isNewCheckoutEnabled) {
    return newCheckout(req, res);
  }
  return legacyCheckout(req, res);
});
```

**Implementação com AWS AppConfig (dinâmica, sem restart):**
- AppConfig permite mudar flags em tempo real
- Aplicação faz polling a cada X segundos
- Mudança de flag = instantâneo, sem restart de container

**Serviços de mercado:**
- **LaunchDarkly:** Líder de mercado, feature flags como serviço, targeting por usuário/segmento
- **AWS AppConfig:** Integrado ao ecossistema AWS, gratuito no nível básico
- **Unleash:** Open-source, self-hosted, boa alternativa gratuita

### 5. Runbooks: O Manual de Emergência

Um runbook é um documento operacional com instruções passo-a-passo para responder a cenários específicos de falha. Diferente de documentação genérica, um runbook é prescritivo: "faça isso, depois aquilo".

**Componentes de um bom runbook:**
- **Trigger:** O que ativa este runbook (ex: health check falhou)
- **Severidade:** P1-P4 (impacto no negócio)
- **Diagnóstico:** Comandos para entender o que está acontecendo
- **Ação:** Passos exatos de remediação
- **Verificação:** Como confirmar que o problema foi resolvido
- **Escalação:** Quem chamar se não resolver em X minutos
- **Post-mortem:** Template para documentar o incidente depois

**Classificação de severidade:**

| Nível | Descrição | Tempo de resposta |
|-------|-----------|:-----------------:|
| P1 | Sistema fora do ar, todos os usuários afetados | Imediato (< 5 min) |
| P2 | Funcionalidade crítica degradada, maioria afetada | < 30 min |
| P3 | Funcionalidade secundária com problemas | < 4 horas |
| P4 | Bug menor, workaround disponível | Próximo dia útil |

### 6. Introdução a AIOps

AIOps (Artificial Intelligence for IT Operations) é a aplicação de IA e ML para automatizar e melhorar operações de TI. Em vez de thresholds fixos e alertas manuais, AIOps usa:

- **Detecção de anomalias:** ML aprende o comportamento normal e alerta quando algo foge do padrão
- **Correlação de eventos:** Identifica que 50 alertas diferentes são causados pelo mesmo problema raiz
- **Análise preditiva:** Prevê falhas antes que ocorram (disco enchendo, memory leak crescendo)
- **Causa raiz automatizada:** IA analisa logs e métricas para sugerir o que causou o problema
- **Remediação sugerida:** IA recomenda (ou executa) a ação corretiva

**Na AWS, os componentes principais são:**
- **CloudWatch Anomaly Detection:** ML embutido para métricas
- **Amazon DevOps Guru:** AIOps managed service (detecta anomalias automaticamente)
- **Amazon Bedrock:** LLMs para análise de logs e geração de insights
- **EventBridge + Lambda:** Orquestração de respostas automáticas (no Learner Lab, a Lambda usa a role pré-existente `LabRole`)

**Comparação: Monitoramento Tradicional vs AIOps:**

| Aspecto | Tradicional | AIOps |
|---------|-------------|-------|
| Threshold | Fixo (CPU > 80%) | Dinâmico (ML aprende) |
| Detecção | Reativo | Preditivo |
| Análise | Manual (humano) | Assistida por IA |
| Correlação | Manual | Automática |
| Falsos positivos | Frequentes | Reduzidos |
| Custo operacional | Alto (equipe 24/7) | Menor (automação) |

### 7. Amazon Bedrock: IA Generativa para Operações

Amazon Bedrock é um serviço managed que oferece acesso a modelos de linguagem (Claude, Titan, Llama) via API. Para AIOps, usamos Bedrock para:

- **Análise de logs:** "Estes logs indicam qual tipo de problema?"
- **Correlação:** "Considerando estas métricas e logs, qual é a causa raiz provável?"
- **Sugestão de ação:** "Qual a melhor ação para resolver este cenário?"
- **Resumo de incidentes:** "Resuma este incidente para o relatório de post-mortem"

**Fluxo típico Lambda + Bedrock:**
1. CloudWatch detecta anomalia → EventBridge dispara evento
2. Lambda coleta contexto (métricas, logs dos últimos 15 min)
3. Lambda envia contexto para Bedrock com prompt estruturado
4. Bedrock retorna análise (causa raiz, severidade, ação recomendada)
5. Lambda notifica equipe e/ou executa remediação automática

**Modelos disponíveis no Bedrock para AIOps:**

| Modelo | Vantagem | Custo (por 1M tokens input) |
|--------|----------|:---------------------------:|
| Claude 3 Haiku | Rápido, barato, bom para análises simples | ~$0.25 |
| Claude 3 Sonnet | Equilíbrio performance/custo | ~$3.00 |
| Claude 3.5 Sonnet | Melhor raciocínio, correlações complexas | ~$3.00 |
| Titan Text | AWS nativo, sem custo de saída de dados | ~$0.80 |

> **💡 Para alertas operacionais, Claude Haiku é suficiente:** resposta em < 2 segundos, baixo custo, boa qualidade para análise de logs.

### 8. Limitações Importantes do AIOps

AIOps é uma tecnologia em evolução. É crucial entender o que funciona e o que não funciona:

**O que funciona bem hoje:**
- Detecção de anomalias em métricas com padrões claros
- Redução de ruído em alertas (agrupar, deduplicar)
- Análise de logs com LLMs (sugerir causa raiz)
- Auto-remediação para cenários simples e bem definidos (restart, scale)

**O que NÃO funciona bem ainda:**
- Substituir completamente o engenheiro de plantão
- Decisões autônomas de rollback sem supervisão humana
- Correlação perfeita em sistemas distribuídos muito complexos
- Previsões com 100% de acerto (falsos positivos ainda existem)

**Recomendação para a TechNova (e para vocês):**
- Use AIOps como **complemento**, não substituto do monitoramento tradicional
- Sempre tenha thresholds fixos como safety net (mesmo com anomaly detection)
- Comece pelo Nível 1 (alerta + sugestão) antes de implementar auto-remediação
- Valide as sugestões da IA antes de automatizar ações

---

## Questões de Múltipla Escolha

### Questão 1

**Na TechNova, o MTTR do incidente de sexta-feira foi de 35 minutos. Qual componente do MTTR pode ser mais reduzido com a implementação de health checks automatizados?**

a) TTR (Time to Recover) — o tempo para executar o rollback
b) TTD (Time to Detect) — o tempo para perceber que algo está errado
c) Tempo de deploy — o tempo para o pipeline executar
d) Tempo de aprovação — o tempo para o PR ser aprovado

### Questão 2

**No padrão Expand-Contract para migrações de banco de dados, qual é a principal razão de manter a coluna antiga durante a fase de transição?**

a) Para economizar espaço em disco, já que colunas antigas são comprimidas
b) Para permitir rollback seguro — a versão anterior do código ainda funciona com o schema
c) Para manter compatibilidade com ferramentas de backup que dependem do schema original
d) Para satisfazer requisitos de auditoria que exigem histórico completo de colunas

### Questão 3

**Qual é a principal vantagem do rollback em um deploy Blue-Green comparado ao Recreate?**

a) O rollback Blue-Green é mais barato pois não requer nova imagem Docker
b) O rollback Blue-Green tem downtime zero pois o ambiente anterior ainda está rodando
c) O rollback Blue-Green é mais seguro pois não altera o banco de dados
d) O rollback Blue-Green é mais rápido pois não precisa fazer pull de imagens

### Questão 4

**Uma feature flag do tipo "Ops flag" (kill switch) é diferente de uma "Release flag" porque:**

a) Ops flags são temporárias e removidas após cada sprint
b) Ops flags controlam acesso baseado em roles do usuário
c) Ops flags são permanentes e servem para emergências operacionais (desligar features com problemas)
d) Ops flags só funcionam em ambiente de produção, nunca em staging

### Questão 5

**No contexto de AIOps, qual é a principal vantagem de thresholds dinâmicos (anomaly detection) sobre thresholds fixos?**

a) Thresholds dinâmicos consomem menos CPU para serem calculados
b) Thresholds dinâmicos são mais fáceis de configurar inicialmente
c) Thresholds dinâmicos se adaptam ao padrão temporal da métrica, reduzindo falsos positivos e detectando degradações graduais
d) Thresholds dinâmicos não requerem armazenamento de dados históricos

### Questão 6

**Na arquitetura Lambda + Bedrock para AIOps, por que a Lambda coleta métricas e logs ANTES de enviar para o Bedrock?**

a) Porque o Bedrock não tem acesso direto ao CloudWatch por questões de segurança
b) Porque a Lambda precisa fornecer contexto relevante para que o LLM faça uma análise precisa da situação
c) Porque o Bedrock cobra por tempo de conexão, e buscar dados previamente reduz custos
d) Porque logs precisam ser criptografados antes de serem enviados para qualquer serviço externo

---

> As respostas das questões serão discutidas no início da aula.

---

## Referências

### Rollback e Deploy Strategies
- Amazon Web Services. **Redeploy and rollback a deployment with CodeDeploy**. AWS Documentation. Disponível em: [https://docs.aws.amazon.com/codedeploy/latest/userguide/deployments-rollback-and-redeploy.html](https://docs.aws.amazon.com/codedeploy/latest/userguide/deployments-rollback-and-redeploy.html)
- Forsgren, N.; Humble, J.; Kim, G. **Accelerate: The Science of Lean Software and DevOps**. IT Revolution Press, 2018. (MTTR e métricas DORA)

### Migrações Reversíveis e Feature Flags
- Prisma. **The Expand and Contract Pattern**. Prisma Data Guide. Disponível em: [https://www.prisma.io/dataguide/types/relational/expand-and-contract-pattern](https://www.prisma.io/dataguide/types/relational/expand-and-contract-pattern)
- Fowler, M. **Feature Toggles (aka Feature Flags)**. martinfowler.com. Disponível em: [https://martinfowler.com/articles/feature-toggles.html](https://martinfowler.com/articles/feature-toggles.html)
- Amazon Web Services. **What is AWS AppConfig?**. AWS Documentation. Disponível em: [https://docs.aws.amazon.com/appconfig/latest/userguide/what-is-appconfig.html](https://docs.aws.amazon.com/appconfig/latest/userguide/what-is-appconfig.html)

### AIOps e Monitoramento Inteligente
- Amazon Web Services. **Using CloudWatch anomaly detection**. AWS Documentation. Disponível em: [https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Anomaly_Detection.html](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Anomaly_Detection.html)
- Amazon Web Services. **What is Amazon Bedrock?**. AWS Documentation. Disponível em: [https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html](https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html)
- Amazon Web Services. **What is Amazon DevOps Guru?**. AWS Documentation. Disponível em: [https://docs.aws.amazon.com/devops-guru/latest/userguide/welcome.html](https://docs.aws.amazon.com/devops-guru/latest/userguide/welcome.html)
