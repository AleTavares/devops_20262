# Entrega — Aula 09: Docker Registry e IA no CI/CD

**Aluno:** José Henrique Teixeira Luiz
**RA:** 3225002
**Data:** 22/10/2026

## Repositório

- URL: https://github.com/zzin742/unifaat-devops-portfolio
- Pasta da aula: [`aula-09/`](https://github.com/zzin742/unifaat-devops-portfolio/tree/main/aula-09)
- Análise: [`aula-09/ia-cicd-analise.md`](https://github.com/zzin742/unifaat-devops-portfolio/blob/main/aula-09/ia-cicd-analise.md)

## Evidências

- [x] Script `ecr-push.sh` publicando no **Amazon ECR** com tags (sha, latest, semver)
- [x] Repositório ECR `technova-api` criado no Learner Lab (`us-east-1`)
- [x] Pull da imagem a partir do ECR funcionando (rollback por tag)
- [x] Workflow de AI Review disparando em PRs
- [x] Quality gate (CRITICAL bloqueia o PR)
- [x] `ia-cicd-analise.md` preenchido
- [ ] Screenshots — as saídas estão coladas abaixo como texto

## 1. Build e push no ECR

```text
==> Garantindo o repositorio ECR 'technova-api'
    criado com scan on push habilitado
==> Aplicando lifecycle policy (mantem 10 imagens; expira untagged em 7 dias)
    aplicada
==> Login no ECR
    autenticado em <CONTA>.dkr.ecr.us-east-1.amazonaws.com
==> Tags que serao publicadas
    sha-1bf6b9c
    latest
    1.2.3
    1.2
    1
==> Push para o ECR
    -> sha-1bf6b9c
    -> latest
    -> 1.2.3 / 1.2 / 1
```

Estado final do repositório:

```text
2026-10-22T09:15:09   47.5 MB   sha-1bf6b9c, 1.2, latest, 1.2.3, 1
```

As cinco tags apontam para a **mesma imagem** — tag em registry é ponteiro, não
cópia.

## 2. Rollback por tag (pull do ECR)

Apaguei a imagem local e puxei de volta:

```text
$ docker rmi -f <CONTA>.dkr.ecr.us-east-1.amazonaws.com/technova-api:sha-1bf6b9c
$ docker pull  <CONTA>.dkr.ecr.us-east-1.amazonaws.com/technova-api:sha-1bf6b9c
✓ pull ok
$ docker run -d -p 3099:3000 ...
/health → {"status":"ok","timestamp":"2026-10-22T12:16:04.587Z","version":"1.0.0"}
```

É esse o teste que valida a estratégia de tagging: de um SHA de commit chego a
um container rodando.

## 3. AI Review + Quality Gate

PR de demonstração: https://github.com/zzin742/unifaat-devops-portfolio/pull/2

Comentário publicado automaticamente pelo workflow:

| Severidade | Quantidade |
|---|---:|
| 🔴 CRITICAL | 6 |
| 🟡 WARNING | 3 |
| 🔵 INFO | 1 |

O workflow terminou **em falha**, bloqueando o merge — é o quality gate
funcionando. Apenas CRITICAL bloqueia; WARNING e INFO passam.

O script detecta **12 padrões** (o bônus pede mais de 8): secret hardcoded,
access key AWS, chave privada, `eval()`, SQL injection, command injection,
`console.log`, `catch {}` vazio, bind em `0.0.0.0`, `http://` sem TLS,
`TODO/FIXME`, e imagem base `:latest`.

## 4. Bônus implementados

| Bônus | Situação |
|---|---|
| Lifecycle policy no ECR | ✅ expira untagged em 7 dias; mantém as 10 `sha-` mais recentes |
| Scan on push | ⚠️ habilitado e confirmado pela AWS, mas **sem resultado** — ver nota |
| Comentário atualizado, não duplicado | ✅ marca `<!-- ai-review-bot -->` e edita o existente |
| Workflow de segurança separado | ✅ `security-scan.yml` com `npm audit` + Trivy e cron semanal |
| Badge no README | ✅ dois |
| Mais de 8 padrões | ✅ **12** |
| Dockerfile com score A no Trivy | ✅ **0 CRITICAL** após correção |

### Nota sobre o scan on push

O repositório foi criado com `scanOnPush=true` e a AWS confirma
(`scanType=BASIC`), mas `describe-image-scan-findings` não devolveu achados e o
`imageScanStatus` veio `null`. O motivo é o formato da imagem: o build saiu de
um Mac ARM via buildx e produziu um **manifest list** multi-arquitetura, que o
scan BASIC do ECR não processa.

Prefiro registrar a limitação a escondê-la. A cobertura de vulnerabilidade não
ficou descoberta: quem a garante é o **Trivy** no `security-scan.yml`, que roda
a cada PR — e foi ele que me fez encontrar a **CVE-2026-59873** (`tar 6.2.1`,
DoS por gzip bomb). Rastreei a origem e ela não vinha das nossas dependências
(`npm audit --omit=dev` dava zero), e sim do **npm embutido na imagem base**. O
runtime não usa npm, então removi `npm`, `npx` e `corepack` da imagem final:

```
antes:  1 CRITICAL
depois: 0 CRITICAL
```

O `/health` continua respondendo — nada no runtime dependia do npm.
