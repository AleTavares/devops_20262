Aluno: Yuri batista sanches
RA: 6325238
Data: 20/08

#### Etapa A: Identificação dos Problemas

| Problema                                   | Classificação | Por quê?                                                                          |
| ------------------------------------------ | ------------- | --------------------------------------------------------------------------------- |
| 1. **4 comandos complexos**                | 🟡 Moderado   | A execução manual é demorada e aumenta a chance de erro.                          |
| 2. **Ninguém lembra a ordem dos comandos** | 🔴 Crítico    | Executar na ordem errada pode causar falhas ou deixar o ambiente inconsistente.   |
| 3. **Senhas espalhadas**                   | 🔴 Crítico    | Aumenta o risco de vazamento de credenciais e problemas de segurança.             |
| 4. **Dados se perdem**                     | 🔴 Crítico    | A perda de dados pode causar prejuízo e necessidade de recriação das informações. |
| 5. **Novos devs sofrem para configurar**   | 🟡 Moderado   | Aumenta o tempo de entrada de novos desenvolvedores e gera retrabalho.            |

#### Etapa B: Design da Solução 

| Problema do Rafael         | Recurso do Docker Compose que resolve                                                                                          |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| **4 comandos complexos**   | `docker compose up` centraliza a criação e inicialização dos serviços.                                                         |
| **Ninguém lembra a ordem** | O `docker-compose.yml` define os serviços e suas dependências, como `depends_on`.                                              |
| **Senhas espalhadas**      | **Variáveis de ambiente** (`environment` / `.env`) centralizam as configurações sensíveis.                                     |
| **Dados se perdem**        | **Volumes** mantêm os dados persistidos mesmo quando o container é removido.                                                   |
| **Novos devs sofrem**      | O `docker-compose.yml` padroniza todo o ambiente, permitindo que o novo desenvolvedor execute basicamente `docker compose up`. |

## Desafio bônus

                 docker-compose.yml
                        |
          ┌─────────────┴─────────────┐
          ↓                           ↓
   ┌─────────────┐             ┌─────────────┐
   │   App/API   │             │  PostgreSQL │
   │  Container  │────────────▶│  Container  │
   └─────────────┘    rede     └─────────────┘
          │                           │
          │                           │
          │                     ┌─────┴─────┐
          │                     │   Volume  │
          │                     │  database │
          │                     └───────────┘
          │
     Variáveis
     de ambiente
          │
        .env

## Parte 2

1. Velocidade vs Qualidade

O Kiro consegue gerar o arquivo muito mais rapidamente do que escrever tudo manualmente. Porém, a qualidade não deve ser considerada equivalente automaticamente, pois o código gerado pela IA precisa ser revisado e testado.

2. Quando confiar

Podemos confiar inicialmente na estrutura básica, como serviços, portas, redes e volumes. Já configurações de segurança, senhas, versões, dependências e persistência devem receber uma verificação extra.

3. Cenário real

O workflow ideal seria Gerar → Revisar → Ajustar → Testar. A IA ajuda a acelerar o desenvolvimento, mas o desenvolvedor deve entender o que foi criado e validar se realmente funciona.

4. Limitações

Se o prompt for muito vago, a IA pode criar uma configuração genérica que não atende às necessidades do projeto. Quanto mais detalhes forem fornecidos sobre serviços, portas, banco de dados, volumes, redes e variáveis, maior a chance de obter um resultado adequado.
