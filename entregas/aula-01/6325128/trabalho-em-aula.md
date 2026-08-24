# Trabalho em Aula — Aula 01: Discussão Guiada

**Aluno:** Felipe Damasceno 
**RA:** 6325128
**Data:** 13/08/2026

## Parte 1 — O Caos do Código

### 1. Problemas identificados (mínimo 4)
- Não existe uma fonte única de verdade, portanto ninguém sabe qual arquivo é a versão correta.
- Alterações são sobrescritas e o histórico de versões não fica registrado.
- O trabalho de uma pessoa pode ser perdido quando outra usa uma cópia antiga.
- Não há como identificar quem alterou cada arquivo, quando a alteração ocorreu ou qual problema foi corrigido.
- A integração entre alterações de pessoas diferentes é manual e pode gerar conflitos difíceis de detectar.
- Recuperar uma versão estável ou comparar duas versões exige procurar arquivos e backups manualmente.

### 2. Impacto financeiro/operacional
- Há perda direta de aproximadamente três dias de trabalho de uma desenvolvedora sênior, além do tempo necessário para refazer as alterações e investigar o que foi perdido.
- A correção urgente pode atrasar a entrega da funcionalidade e aumentar o risco de indisponibilidade ou de novos defeitos no módulo de pagamentos.
- A equipe perde produtividade, o atendimento ao cliente pode ser afetado e a empresa pode ter custos com horas extras, retrabalho e incidentes em produção.
- Também há perda de confiança no processo de desenvolvimento e dificuldade para auditar responsabilidades e decisões técnicas.

### 3. Como o Git resolve

| Problema Identificado | Como o Git Resolve |
|---|---|
| Não saber qual versão é a correta | O repositório compartilhado e a branch `main` representam a fonte oficial de verdade; tags podem identificar versões liberadas. |
| Sobrescrever alterações e perder trabalho | Cada alteração é registrada em commits imutáveis; branches e pull requests permitem trabalhar sem apagar o trabalho de outra pessoa. |
| Não conseguir recuperar uma versão anterior | O histórico permite comparar commits e restaurar uma versão conhecida usando `revert` ou checkout de um commit. |
| Não saber quem fez cada alteração | Cada commit registra autor, data e mensagem, permitindo auditoria com `log` e `blame`. |
| Dificuldade para combinar alterações | O Git identifica conflitos entre branches e oferece ferramentas para resolvê-los antes da integração. |
| Falta de validação antes de publicar | Pull requests podem exigir revisão, testes automatizados e aprovação antes do merge na `main`. |

### 4. Regras ao adotar Git
- Usar a `main` apenas para código estável e criar uma branch por tarefa, como `feature/filtro-pedidos` ou `fix/erro-pagamento`.
- Fazer commits pequenos, frequentes e relacionados a uma única mudança, com mensagens claras no imperativo.
- Sincronizar a branch com o repositório remoto antes de abrir o pull request e não sobrescrever o trabalho de outras pessoas.
- Exigir pull request, revisão por pelo menos uma pessoa e execução dos testes antes do merge.
- Proteger a `main`, proibindo push direto e exigindo verificações de CI.
- Usar `.gitignore` para não versionar segredos, dependências, arquivos de build ou dados locais.
- Nunca colocar senhas ou chaves no repositório; utilizar variáveis de ambiente e um gerenciador de segredos.
- Criar tags e releases para versões disponibilizadas aos usuários.

## Parte 2 — "Funciona na Minha Máquina"

### 5. Causa Raiz (3 categorias)
- Dependências: o pacote `date-fns` não foi declarado ou instalado de forma consistente, e versões diferentes de módulos nativos como `bcrypt` podem exigir bibliotecas distintas.
- Runtime: os ambientes usam versões diferentes do Node.js (20.11, 18.12, 20.9 e 18.17), o que pode mudar APIs e comportamentos.
- Sistema operacional e infraestrutura: macOS, Ubuntu e Windows possuem bibliotecas, compiladores, arquitetura e versões de `libssl` diferentes; isso explica a incompatibilidade do `bcrypt` no staging e parte do comportamento de datas.

### 6. Requisitos da solução
- Isolamento: cada aplicação deve executar com suas próprias dependências, versões e configurações, sem interferir no sistema hospedeiro.
- Reprodutibilidade: o mesmo código deve produzir um ambiente equivalente a partir de arquivos versionados, como `Dockerfile`, `package.json` e `package-lock.json`.
- Portabilidade: a imagem deve executar de maneira consistente em laptops, CI e servidores compatíveis com Docker.
- Leveza: a solução deve compartilhar o kernel do host e conter somente a aplicação e as dependências necessárias, inicializando rapidamente.

### 7. Container vs. VM

| Aspecto | VM | Container |
|---|---|---|
| Tempo de inicialização | Minutos, pois inicializa um sistema operacional completo. | Segundos ou menos, pois inicia apenas os processos da aplicação. |
| Uso de disco | Alto, com uma imagem completa do sistema operacional por VM. | Menor, pois as imagens compartilham camadas e o kernel do host. |
| Consumo de memória | Alto, com memória reservada para cada sistema operacional. | Menor, pois os processos compartilham o kernel. |
| Facilidade de versionamento | Mais pesada; normalmente exige snapshots ou imagens grandes. | Alta; imagens são descritas por `Dockerfile`, versionadas e reproduzíveis. |
| Densidade no servidor | Menor, com menos VMs por host. | Maior, com mais containers usando os mesmos recursos. |

### 8. Git + Docker juntos
1. O desenvolvedor clona o repositório Git e muda para a branch da tarefa.
2. Ele instala ou utiliza o Docker e executa `docker compose up --build` (ou o comando documentado pelo projeto).
3. O Docker constrói a imagem a partir do `Dockerfile`, instala as dependências fixadas pelo `package-lock.json` e configura a mesma versão de Node e do sistema para todos.
4. O desenvolvedor executa os testes dentro do container, implementa a alteração, registra commits e envia a branch para o repositório remoto.
5. O CI constrói a mesma imagem, executa os testes e verifica o pull request. Após a revisão e o merge, a imagem versionada é publicada e usada no staging e na produção.

Assim, o Git garante histórico, colaboração e rastreabilidade do código e dos arquivos de configuração, enquanto o Docker padroniza o ambiente de execução e elimina diferenças entre máquinas.

## Parte 3 — Proposta para o CTO
Carlos, propomos implementar Git com branches, pull requests e CI para controlar versões, revisar alterações e evitar perda de trabalho. Também propomos usar Docker com `Dockerfile` e dependências fixadas para garantir ambientes isolados e reproduzíveis. Com isso, a equipe da TechNova poderá colaborar com rastreabilidade e executar a API de forma consistente no desenvolvimento, no staging e na produção, sem depender de cópias manuais ou do ambiente de uma única máquina.