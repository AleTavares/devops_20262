# Trabalho em Aula — Aula 01: Discussão Guiada

**Aluno:** Denise Maider Batista de Macedo
**RA:** 6325028
**Disciplina:** DevOps
**Professor:** Alexandre Tavares

## Parte 1 — O Caos do Código

### 1. Problemas identificados

- Ausência de controle de versão.
- Perda de alterações realizadas pelos desenvolvedores.
- Dificuldade para identificar a versão mais atualizada.
- Sobrescrita de arquivos.
- Ausência de histórico e rastreabilidade.

### 2. Impacto financeiro e operacional

A falta de controle de versão gera retrabalho, desperdício de tempo, atrasos nas entregas e aumento dos custos operacionais. Também prejudica a qualidade do sistema e a colaboração entre os desenvolvedores.

### 3. Como o Git resolve

| Problema identificado | Como o Git resolve |
|---|---|
| Perda de código | Permite recuperar versões anteriores pelo histórico de commits. |
| Sobrescrita de arquivos | Permite trabalhar em branches independentes. |
| Dificuldade para identificar a versão atual | Mantém uma branch principal como referência. |
| Falta de rastreabilidade | Registra autores, datas e alterações dos commits. |
| Dificuldade de colaboração | Permite integrar alterações e realizar revisões por Pull Requests. |

### 4. Regras ao adotar Git

- Criar branches específicas para funcionalidades e correções.
- Realizar commits frequentes com mensagens descritivas.
- Atualizar o repositório local antes de iniciar novas atividades.
- Utilizar Pull Requests para revisão do código.
- Evitar alterações diretamente na branch main.
- Não versionar senhas ou credenciais.
- Testar o código antes de integrar as alterações.

## Parte 2 — Funciona na Minha Máquina

### 5. Causa raiz

- Sistemas operacionais: diferenças entre Windows, Linux e macOS.
- Versões das ferramentas: diferentes versões do Node.js.
- Dependências e bibliotecas: ausência ou incompatibilidade de módulos como date-fns, libssl e bcrypt.

### 6. Requisitos da solução

- Isolamento: executar cada aplicação em seu próprio ambiente.
- Reprodutibilidade: garantir ambientes com configurações e dependências equivalentes.
- Portabilidade: executar a aplicação em diferentes máquinas compatíveis com Docker.
- Leveza: reduzir o consumo de recursos computacionais.

### 7. Container vs. VM

| Aspecto | Máquina Virtual | Container |
|---|---|---|
| Tempo de inicialização | Geralmente mais demorado | Geralmente mais rápido |
| Uso de disco | Maior | Menor |
| Consumo de memória | Geralmente maior | Geralmente menor |
| Velocidade | Maior sobrecarga de virtualização | Menor sobrecarga |
| Facilidade de versionamento | Mais complexa | Facilitada pelo Dockerfile e pelas imagens |
| Densidade no servidor | Menor | Maior |

### 8. Git e Docker juntos

O Git permite controlar as versões do código, registrar alterações e facilitar a colaboração entre os desenvolvedores.

O Docker padroniza o ambiente de execução, incluindo as dependências e configurações necessárias para a aplicação.

Juntas, essas ferramentas reduzem problemas de incompatibilidade, perdas de código e retrabalho, tornando o desenvolvimento mais organizado e reproduzível.

## Parte 3 — Proposta para o CTO

Propomos implementar Git para controlar as versões do código e melhorar a colaboração entre os desenvolvedores.
Utilizaremos Docker para padronizar os ambientes de desenvolvimento e execução.
Com essas ferramentas, esperamos reduzir o retrabalho, evitar perdas de código e minimizar incompatibilidades.
Dessa forma, a TechNova terá um processo de desenvolvimento mais eficiente, organizado e confiável.
