# Aula 15 — Trabalho Anterior (TA): Preparação da Apresentação Final

## Objetivo

Preparar-se para a **Apresentação Final** do curso. Diferente das demais aulas, aqui o TA não é uma leitura de conceito novo: é a **organização do que você vai apresentar**. Nesta aula você mostra, de ponta a ponta, o portfólio `unifaat-devops-portfolio` que construiu ao longo do curso — da fundação em Git/Docker até o projeto integrador com CI/CD, Amazon ECR, deploy com zero downtime e IA. Ao final desta preparação, você deve ter a apresentação estruturada, a demo testada e o portfólio verificado.

> **Como estudar este material:** leia o roteiro, monte sua apresentação a partir do template, rode o checklist de preparação da demo e do portfólio, e responda as questões de auto-avaliação ao final. Traga tudo pronto e ensaiado para a aula.

---

## Contexto Narrativo

> A diretoria da TechNova convocou uma reunião geral. Cada engenheiro DevOps vai apresentar o
> que construiu durante o programa de transformação digital. O CEO, a CTO e os líderes
> técnicos estarão presentes. É hora de mostrar resultados — do caos da Aula 01 à plataforma
> automatizada de hoje.

---

## Parte 1 — Estruturar a Apresentação

Prepare uma apresentação seguindo este template de slides. O foco é **mostrar o pipeline funcionando** e **articular a jornada**, não acumular slides.

| Slide | Conteúdo |
|-------|----------|
| 1 | Título + Nome + link do repositório `unifaat-devops-portfolio` |
| 2 | Diagrama da arquitetura final (AWS no Learner Lab) |
| 3 | Stack tecnológica (Git, Docker, Terraform, GitHub Actions, Amazon ECR, Bedrock) |
| 4 | Demo: pipeline CI/CD ao vivo (push → CI → build → push no ECR → deploy) |
| 5 | Demo: integração de IA (review de PR, IaC gerada por IA, ou agente Bedrock) |
| 6 | Antes vs Depois (Aula 01 → 15) |
| 7 | Desafios e soluções |
| 8 | Próximos passos |
| 9 | Perguntas |

**Formato aceito:** slides (Google Slides, PowerPoint, Marp), demo ao vivo com terminal, ou combinação dos dois. O que vale é demonstrar o sistema real.

---

## Parte 2 — Preparar a Demo ao Vivo

Verifique que sua demo funciona **antes** da aula. O ponto central da apresentação é o pipeline end-to-end rodando de verdade.

```bash
# 1. Pipeline CI/CD
git checkout -b demo/aula-15
echo "# Demo Aula 15" >> demo-test.md
git add demo-test.md
git commit -m "feat: demo aula 15 - apresentacao final"
git push origin demo/aula-15
# → Verificar: CI dispara? Lint/test/build passam? Imagem publicada no Amazon ECR?

# 2. Integração IA
# → Criar PR e mostrar o review automático
# → Ou demonstrar geração/validação de IaC com assistente, ou o agente Bedrock

# 3. Aplicação rodando
docker compose up -d
curl http://localhost:3000/health
# → Verificar: aplicação responde?
```

> **☁️ Learner Lab:** se a demo publica a imagem no **Amazon ECR** ou provisiona recursos
> (EC2, ALB, RDS, Bedrock), inicie a sessão do Lab antes e confirme as credenciais
> temporárias (`aws sts get-caller-identity`, região `us-east-1`). As credenciais do Lab
> **expiram por sessão** — recarregue-as antes de apresentar.

**Plano B:** grave um vídeo da demo caso algo falhe no dia (ou se a sessão do Lab expirar). Ter um backup é DevOps na prática.

---

## Parte 3 — Praticar a Narrativa

Pratique contando a história da evolução. Use este roteiro como ponto de partida:

> "Na Aula 01, a TechNova tinha [problema X]. Ao longo do curso, implementamos [solução Y].
> Hoje, temos [resultado Z]. O maior desafio foi [desafio]. A maior lição foi [lição]."

**Dica:** ensaie com cronômetro e respeite o tempo combinado pelo professor. Entenda o que construiu — não decore.

---

## Parte 4 — Verificar o Portfólio

Confirme que o repositório `unifaat-devops-portfolio` está completo, público e alinhado ao conteúdo real do curso (a orquestração em produção usa **EC2/ALB via Terraform** no Learner Lab, sem plataformas de orquestração de containers):

```
unifaat-devops-portfolio/
├── README.md                 (resumo da jornada)
├── git-docker/               (Git + Docker: imagens, Dockerfile)
├── docker-compose/           (orquestração local)
├── ia-copiloto/              (Kiro / prompting para IaC)
├── terraform-aws/            (Terraform: IAM, VPC, EC2, RDS)
├── terraform-state-modules/  (remote state S3/DynamoDB + módulos)
├── ci-github-actions/        (CI: lint, test, build, Secrets)
├── registry-ecr/             (Amazon ECR + IA no CI/CD)
├── cd-gitops/                (GitOps e pipelines de CD)
├── deploy-blue-green-canary/ (Blue/Green e Canary)
├── rollback-aiops/           (rollback, feature flags, AIOps)
├── projeto-integrador/       (microserviço E2E + agente Bedrock)
├── app-technova/             (código da aplicação)
├── infra/                    (código de infraestrutura — Terraform)
├── .github/workflows/        (pipelines CI/CD)
└── docker-compose.yml
```

> A estrutura exata de pastas é livre — o importante é que o portfólio **demonstre a jornada
> completa do curso**, com código funcional e documentação clara em cada etapa.

---

## Checklist de Preparação

- [ ] Apresentação estruturada (slides ou roteiro)
- [ ] Demo do pipeline testada e funcional (CI → push no Amazon ECR → deploy)
- [ ] Demo da IA testada e funcional (review de PR, IaC por IA ou agente Bedrock)
- [ ] Plano B preparado (vídeo/screenshots)
- [ ] Portfólio no GitHub completo e **público**
- [ ] `README.md` do portfólio atualizado (jornada de aprendizagem)
- [ ] Credenciais do Learner Lab carregadas e válidas (se a demo usar AWS)
- [ ] Ensaio da apresentação realizado com cronômetro
- [ ] Auto-avaliação preenchida (abaixo)

---

## Questões de Verificação (Auto-Avaliação)

Responda honestamente antes de apresentar. Elas ajudam a identificar lacunas enquanto ainda há tempo de corrigir.

### Questão 1

Na demo do pipeline, qual é a ordem correta das etapas que você vai mostrar end-to-end?

- a) Deploy → build → testes → push para o registry
- b) Push de código → CI (lint/test/build) → push da imagem no **Amazon ECR** → deploy
- c) Build local → cópia manual para o servidor → restart
- d) Apenas `docker compose up` na máquina local

### Questão 2

Durante a apresentação, qual registry de imagens o seu pipeline usa e em qual ambiente ele roda?

- a) Docker Hub público, em conta pessoal AWS
- b) **Amazon ECR**, no **AWS Academy Learner Lab** (`us-east-1`, credenciais temporárias)
- c) ghcr.io (registry alternativa fora do padrão do curso), sem relação com a AWS
- d) Nenhum — a imagem fica só no runner do CI

### Questão 3

Se a sessão do Learner Lab expirar bem no meio da sua demo, qual é a atitude mais adequada (DevOps na prática)?

- a) Encerrar a apresentação, pois nada mais funciona
- b) Recriar toda a infraestrutura do zero na hora
- c) Explicar o que deveria acontecer e recorrer ao **plano B** (vídeo/screenshots)
- d) Pedir para outro aluno apresentar no seu lugar

### Questão 4

Qual integração de IA você consegue demonstrar no seu fluxo, entre as que o curso cobriu?

- a) Nenhuma — IA não faz parte do curso
- b) Apenas autocompletar de código no editor
- c) Review automático de PR, geração/validação de IaC ou um agente DevOps com **AWS Bedrock**
- d) Treinar um modelo de ML do zero durante a demo

### Questão 5

Para a narrativa de evolução (Aula 01 → 15), o que demonstra melhor seu aprendizado?

- a) Afirmar que tudo sempre funcionou perfeitamente
- b) Contar o estado inicial, o que mudou e o maior desafio real que você superou
- c) Listar apenas as ferramentas, sem contexto
- d) Omitir os problemas enfrentados durante o curso

---

> As respostas e a auto-avaliação orientam sua preparação; eventuais dúvidas serão discutidas no início da aula.

---

## Referências

### Preparação de Apresentações Técnicas e Portfólio

- GitHub. **About READMEs**. GitHub Docs. Disponível em: [https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes)
- GitHub. **Setting repository visibility (público/privado)**. GitHub Docs. Disponível em: [https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/managing-repository-settings/setting-repository-visibility](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/managing-repository-settings/setting-repository-visibility)

### Pipeline, Registry e Demo

- Amazon Web Services. **What is Amazon Elastic Container Registry?**. AWS Documentation. Disponível em: [https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html)
- GitHub. **About continuous integration with GitHub Actions**. GitHub Docs. Disponível em: [https://docs.github.com/en/actions/automating-builds-and-tests/about-continuous-integration](https://docs.github.com/en/actions/automating-builds-and-tests/about-continuous-integration)
- Amazon Web Services. **Amazon Bedrock — Foundation Models**. AWS Documentation. Disponível em: [https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html](https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html)

### Maturidade e Prática DevOps

- FORSGREN, Nicole; HUMBLE, Jez; KIM, Gene. **Accelerate: The Science of Lean Software and DevOps**. Portland: IT Revolution Press, 2018.
- KIM, Gene; HUMBLE, Jez; DEBOIS, Patrick; WILLIS, John. **O Projeto Fênix**. Rio de Janeiro: Alta Books, 2018.

---

*Boa preparação! Chegou o grande dia.* 🚀
