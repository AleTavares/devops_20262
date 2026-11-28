# Entrega — Aula 11 (TF)

**Aluno:** Emar Cristian Silva Teruo Ito
**RA:** 6325192
**Data:** 19/11/2026

## Fork do projeto

- URL: https://github.com/iHawlKz7/implement_Moodle
- Commit desta semana: https://github.com/iHawlKz7/implement_Moodle/commit/af9190983f9f78b7f88eeeb526d08cc9b8b00ee5
- Spec: https://github.com/iHawlKz7/implement_Moodle/tree/af9190983f9f78b7f88eeeb526d08cc9b8b00ee5/.kiro/specs/moodle-aws

## O que foi feito nesta aula

- Criei o fork do Moodle Docker AWS Challenge, clonei o projeto e preparei a branch de desenvolvimento.
- Analisei o enunciado da prova, o README, o CHALLENGE e os requisitos da documentação e dos testes.
- Conferi a disponibilidade de Docker, Docker Compose, Terraform, AWS CLI, Git e Python no WSL2.
- Configurei o Kiro e iniciei uma Feature Spec pelo fluxo nativo Requirements-first.
- Revisei os 16 requisitos gerados pelo Kiro, incluindo os módulos networking, compute e database.
- Registrei os critérios de segurança, CI/CD, arquitetura, evidências e entrega acadêmica.
- A etapa de Requirements foi concluída e validada pelo Kiro; os arquivos da Spec foram publicados neste checkpoint.
- A execução do Moodle local, o Tech Design, as Tasks, a implementação Terraform e os testes ainda estão pendentes.
- O próximo passo é gerar o Design da Spec, validar o ambiente Docker e avançar na implementação planejada.
- Utilizei Kiro para elaborar e manter a Spec e ChatGPT para revisar os requisitos e orientar o fluxo de trabalho.

## Dificuldades encontradas

O template e o enunciado da prova apresentavam diferenças, especialmente no nome do instance profile IAM, na quantidade de subnets e no tipo de instância EC2. Revisei os critérios para priorizar a prova, incluindo LabInstanceProfile, duas subnets públicas e duas privadas e EC2 t3.micro. Também ocorreram dificuldades na gravação do requirements.md por comandos PowerShell e WSL. Interrompi as tentativas de sobrescrita e solicitei a edição pela ferramenta nativa do Kiro, que confirmou a gravação e a validação dos 16 requisitos. A infraestrutura AWS ainda não foi provisionada nesta etapa.
