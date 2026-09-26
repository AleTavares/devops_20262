# Trabalho em Aula — Aula 01: Discussão Guiada

**Aluno:** Maximus Ponciano  
**RA:** 6325066  
**Data:** 18/08/2026  

## Parte 1 — O Caos do Código

### 1. Problemas identificados
- **Falta de uma Fonte Única da Verdade (Single Source of Truth):** Diversas cópias `.zip` compactadas no servidor sem indicação clara de qual continha o código atualizado de produção.
- **Sobrescrita de código e perda de trabalho:** Alterações feitas por outros membros da equipe (ex: 3 dias de trabalho da Juliana) foram permanentemente sobrescritas por falta de controle de concorrencia.
- **Ausência de rastreabilidade e histórico:** Impossibilidade de saber quem alterou determinado trecho de código, quando a mudança foi feita e por qual motivo.
- **Impossibilidade de Rollback rápido:** Em caso de falha grave, não havia mecanismo simples para restaurar uma versão funcional anterior.
- **Inexistência de processo de revisão de código:** Qualquer alteração era inserida diretamente no ambiente sem revisão prévia por outros desenvolvedores.

### 2. Impacto financeiro/operacional
A perda de trabalho gera desperdício direto de horas de desenvolvimento pagas (como o tempo de profissionais sêniores), além de reavaliações de prazos que atrasam entregas importantes de negócio. Operacionalmente, a equipe precisa parar o fluxo normal para refazer e revalidar código perdido, elevando custos com horas extras, gerando atrito na equipe e expondo a empresa a falhas graves no módulo de pagamentos em produção.

### 3. Como o Git resolve

| Problema Identificado | Como o Git Resolve |
|---|---|
| Múltiplos arquivos `.zip` desorganizados | Branch `main` atua como fonte única e confiável de código |
| Sobrescrita acidental de código | Workflow em branches isoladas e merge controlado |
| Falta de histórico e autoria das mudanças | Commits registrados com hash único, autor, data e mensagem descritiva |
| Dificuldade para reverter erros | Comandos como `git revert` e `git checkout` restauram qualquer estado anterior |
| Conflitos de edição simultânea | O Git identifica conflitos de merge e exige resolução manual orientada |
| Falta de revisão prévia | Pull Requests obrigatórios para validação e Code Review antes da integração |

### 4. Regras ao adotar Git
- Proteger a branch `main` proibindo commits e pushes diretos.
- Criar branches específicas para cada funcionalidade ou correção (ex: `feature/aula-01-app` ou `fix/mod-pagamento`).
- Realizar commits frequentes, atômicos e com mensagens claras (seguindo o padrão *Conventional Commits*: `feat:`, `fix:`, `docs:`, `chore:`).
- Abrir Pull Request (PR) e obter aprovação via Code Review antes de realizar o merge para a branch principal.
- Utilizar arquivo `.gitignore` configurado desde o início para não versionar arquivos temporários, logs, dependências (`node_modules`) ou credenciais sensíveis.

---

## Parte 2 — "Funciona na Minha Máquina"

### 5. Causa Raiz (3 categorias)
1. **Diferenças nas versões de runtime/execução:** Incompatibilidade entre as versões instaladas do Node.js (ex: Node 20.11 no macOS vs Node 18.12 no Ubuntu vs Node 20.9 no Windows).
2. **Dependências da aplicação mal padronizadas:** Módulo de dependência (`date-fns`) ausente ou não instalado de forma consistente entre os ambientes.
3. **Incompatibilidade de sistema operacional e bibliotecas nativas:** Bibliotecas nativas C/C++ compiladas para o SO (ex: `libssl` e `bcrypt`) que variam entre macOS, Windows e Ubuntu Linux Staging.

### 6. Requisitos da solução
- **Isolamento:** A aplicação deve rodar encapsulada em seu próprio ambiente, sem depender nem interferir em dependências globais instaladas no sistema operacional hospedeiro.
- **Reprodutibilidade:** Garantir que o processo de build (via `Dockerfile`) produza exatamente a mesma imagem e comportamento independente de onde for executado.
- **Portabilidade:** A imagem do container deve rodar de forma idêntica no laptop do desenvolvedor (Windows, Mac ou Linux), no servidor de staging e na nuvem em produção.
- **Leveza:** O ambiente deve subir em poucos segundos e consumir o mínimo de recursos computacionais (CPU/RAM).

### 7. Container vs. VM

| Aspecto | VM | Container |
|---|---|---|
| Tempo de inicialização | Minutos (precisa dar boot no SO completo) | Segundos (inicializa apenas o processo) |
| Uso de disco | Alto (Gigabytes por instância) | Baixo (Megabytes, reutiliza camadas de imagem) |
| Consumo de memória | Alto (reserva fixa de RAM para o SO convidado) | Baixo (compartilha o kernel do SO host) |
| Facilidade de versionamento | Baixa (arquivos `.iso`/`.vmdk` pesados e difíceis de versionar) | Alta (`Dockerfile` leve armazenado e versionado via Git) |
| Densidade no servidor | Baixa (poucas VMs por hardware físico) | Alta (dezenas ou centenas de containers por host) |

### 8. Git + Docker juntos
O Git armazena e versiona tanto o código da aplicação quanto as receitas de infraestrutura (`Dockerfile` e `docker-compose.yml`). Quando um novo desenvolvedor entra no time, ele realiza o `git clone` do repositório e executa `docker build` / `docker run`. Dessa forma, o Git garante a versão exata do código e o Docker garante a padronização exata do ambiente de execução, extinguindo definitivamente o problema do "funciona na minha máquina".

---

## Parte 3 — Proposta para o CTO

Propomos implementar o Git para controle de versão e o Docker para a padronização dos ambientes na TechNova. Com o Git, garantimos o histórico do código, rastreabilidade e colaboração segura via branches e Pull Requests. Com o Docker, encapsulamos a aplicação em um container idêntico em todas as etapas, desde o desenvolvimento até o ambiente de testes e produção. Esta combinação elimina a perda de código e garante entregas rápidas, confiáveis e reproduzíveis.
