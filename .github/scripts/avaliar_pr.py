#!/usr/bin/env python3
"""
Avalia um PR de Trabalho de Fixacao (TF) da disciplina e comenta o parecer no PR.

Fluxo:
  1. Le os dados do PR (titulo, arquivos, entrega.md) via API do GitHub.
  2. Identifica a aula pelo titulo (ex.: "[Aula 03] ...").
  3. Le os criterios em aula-XX/TF.md (do proprio repo da disciplina).
  4. Extrai o link do portfolio no entrega.md e lista/le os arquivos .tf.
  5. Roda um pre-check deterministico (arquivos obrigatorios, .tfstate, etc.).
  6. Opcionalmente chama o Amazon Bedrock para gerar o parecer + nota.
  7. Posta um comentario no PR (atualiza o comentario anterior do bot, se houver).

Depende apenas de: requests, boto3.
Nao executa nenhum codigo vindo do fork; so faz leitura de dados e chamadas de API.
"""
import json
import os
import re
import sys
import urllib.parse

import requests

GITHUB_API = "https://api.github.com"
BOT_MARKER = "<!-- avaliador-tf-bot -->"  # marcador para achar/atualizar o comentario


# ---------------------------------------------------------------------------
# Helpers de HTTP
# ---------------------------------------------------------------------------
def gh_headers(token):
    h = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    if token:
        h["Authorization"] = f"Bearer {token}"
    return h


def get_json(url, headers=None):
    resp = requests.get(url, headers=headers or {}, timeout=30)
    if resp.status_code == 404:
        return None
    resp.raise_for_status()
    return resp.json()


def get_text(url, headers=None):
    resp = requests.get(url, headers=headers or {}, timeout=30)
    if resp.status_code == 404:
        return None
    resp.raise_for_status()
    return resp.text


# ---------------------------------------------------------------------------
# Coleta de dados do PR
# ---------------------------------------------------------------------------
def fetch_pr(repo, pr_number, token):
    h = gh_headers(token)
    pr = get_json(f"{GITHUB_API}/repos/{repo}/pulls/{pr_number}", h)
    files = get_json(f"{GITHUB_API}/repos/{repo}/pulls/{pr_number}/files", h) or []
    return pr, files


def find_entrega_md(repo, files, base_sha, token):
    """Acha o entrega.md alterado no PR e retorna (path, conteudo)."""
    h = gh_headers(token)
    for f in files:
        if f["filename"].endswith("entrega.md"):
            raw = f.get("raw_url")
            content = get_text(raw, h) if raw else None
            if content is None:
                # fallback pela Contents API no ref do PR
                url = f"{GITHUB_API}/repos/{repo}/contents/{urllib.parse.quote(f['filename'])}?ref={base_sha}"
                data = get_json(url, h)
                if data and data.get("download_url"):
                    content = get_text(data["download_url"], h)
            return f["filename"], content
    return None, None


def detect_aula(title):
    """
    Extrai o identificador da entrega a partir do titulo do PR.
    - Prova do 1o bimestre -> 'provaPrimeiroBi'
    - Aulas: '[Aula 03] ...' -> '03'
    """
    # Prova do primeiro bimestre (varias grafias aceitas no titulo)
    if re.search(r"prova.*bimestre|primeiro\s*bimestre|prova\s*primeiro\s*bi|provaprimeirobi",
                 title, re.IGNORECASE):
        return "provaPrimeiroBi"
    m = re.search(r"aula[\s\-_]*0*(\d+)", title, re.IGNORECASE)
    if m:
        return f"{int(m.group(1)):02d}"
    return None


def detect_ra(title):
    m = re.search(r"RA[:\s]*([0-9]{4,})", title, re.IGNORECASE)
    return m.group(1) if m else None


def read_local_criteria(aula):
    """
    Le os criterios da entrega no repositorio da disciplina (checkout local).
    - Prova do 1o bimestre: provas/prova-primeiro-bimestre.md
    - Aulas: aula-XX/TF.md
    """
    if aula == "provaPrimeiroBi":
        path = os.path.join("provas", "prova-primeiro-bimestre.md")
    else:
        path = os.path.join(f"aula-{aula}", "TF.md")
    if os.path.exists(path):
        with open(path, encoding="utf-8") as fh:
            return fh.read()
    return None


def extract_portfolio(entrega_md, aula=None):
    """
    Extrai owner/repo do link do repositorio do aluno no entrega.md.
    - Prova do 1o bimestre: repo 'prova-primeiro-bimestre-devops'
    - Aulas: repo 'unifaat-devops-portfolio'
    """
    if not entrega_md:
        return None
    repo_name = ("prova-primeiro-bimestre-devops"
                 if aula == "provaPrimeiroBi" else "unifaat-devops-portfolio")
    m = re.search(rf"github\.com/([\w.-]+)/({re.escape(repo_name)})", entrega_md)
    if m:
        return m.group(1), m.group(2)
    return None


# ---------------------------------------------------------------------------
# Pre-check deterministico no portfolio
# ---------------------------------------------------------------------------
REQUIRED_BY_AULA = {
    "03": ["providers.tf", "main.tf", "policies.tf", "roles.tf",
           "variables.tf", "outputs.tf", "README.md", ".gitignore",
           "terraform-plan-output.txt"],
    "04": ["providers.tf", "main.tf", "variables.tf", "outputs.tf",
           "README.md", ".gitignore"],
    "05": ["providers.tf", "main.tf", "variables.tf", "outputs.tf",
           "README.md", ".gitignore"],
    "06": ["providers.tf", "main.tf", "variables.tf", "outputs.tf",
           "README.md", ".gitignore"],
    "02": ["docker-compose.yml", "Dockerfile", "app.js", "package.json",
           ".gitignore", "ia-analise.md"],
}

# Aulas conceituais em que o codigo e entregue DENTRO do proprio PR
# (pasta entregas/aula-XX/RA/), nao no repositorio de portfolio.
# Nao usam AWS/Terraform. O que mais vale e o processo-spec.md.
AULAS_CODIGO_NO_PR = {
    "07": {
        "obrigatorios": ["processo-spec.md", "package.json"],
        # pelo menos um arquivo .js (server.js ou equivalente) deve existir
        "exige_js": True,
        "rotas_esperadas": [
            "POST /salas", "GET /salas", "POST /reservas",
            "DELETE /reservas", "GET /reservas",
        ],
    },
}


# Estrutura esperada no repositorio proprio da Prova do 1o Bimestre.
# Aqui verificamos caminhos (arquivos/pastas), pois a prova tem subpastas
# (app/, infra/, evidencias/) em vez de arquivos .tf na raiz.
PROVA_ESTRUTURA = {
    "raiz_obrigatorios": ["README.md", ".gitignore", "docker-compose.yml", "relatorio.md"],
    "pastas_obrigatorias": ["app", "infra"],
    "infra_modulos": ["vpc", "security-group", "ec2", "rds"],
}


def _list_dir(owner, repo, path, branch, token):
    """Lista o conteudo de um diretorio do repo (ou [] se nao existir)."""
    h = gh_headers(token)
    url = (f"{GITHUB_API}/repos/{owner}/{repo}/contents/"
           f"{urllib.parse.quote(path)}?ref={urllib.parse.quote(branch)}")
    listing = get_json(url, h)
    return listing if isinstance(listing, list) else []


def precheck_prova(owner, repo, token):
    """
    Pre-check para a Prova do 1o Bimestre: valida a estrutura do repositorio
    proprio do aluno (raiz + app/ + infra/modules/*), sem exigir arquivos .tf
    soltos na raiz. So faz leitura via API.
    """
    result = {
        "modo": "prova",
        "repo_encontrado": False,
        "branch": None,
        "raiz_presentes": [],
        "raiz_faltando": [],
        "pastas_presentes": [],
        "pastas_faltando": [],
        "modulos_presentes": [],
        "modulos_faltando": [],
        "tem_dockerfile": False,
        "tfstate_versionado": False,
        "observacoes": [],
    }
    h = gh_headers(token)
    repo_info = get_json(f"{GITHUB_API}/repos/{owner}/{repo}", h)
    if not repo_info:
        result["observacoes"].append(
            f"Repositorio da prova nao encontrado: {owner}/{repo}")
        return result
    result["repo_encontrado"] = True
    branch = repo_info.get("default_branch", "main")
    result["branch"] = branch

    raiz = _list_dir(owner, repo, "", branch, token)
    nomes_raiz = {item["name"]: item for item in raiz}

    for req in PROVA_ESTRUTURA["raiz_obrigatorios"]:
        (result["raiz_presentes"] if req in nomes_raiz
         else result["raiz_faltando"]).append(req)

    for pasta in PROVA_ESTRUTURA["pastas_obrigatorias"]:
        if pasta in nomes_raiz and nomes_raiz[pasta].get("type") == "dir":
            result["pastas_presentes"].append(pasta)
        else:
            result["pastas_faltando"].append(pasta)

    # Dockerfile da API (pode estar em app/ ou app/*)
    if "app" in result["pastas_presentes"]:
        app_listing = _list_dir(owner, repo, "app", branch, token)
        app_names = {i["name"] for i in app_listing}
        if "Dockerfile" in app_names:
            result["tem_dockerfile"] = True
        else:
            # procura Dockerfile na raiz como fallback
            result["tem_dockerfile"] = "Dockerfile" in nomes_raiz
    else:
        result["tem_dockerfile"] = "Dockerfile" in nomes_raiz
    if not result["tem_dockerfile"]:
        result["observacoes"].append("Dockerfile da API nao encontrado (esperado em app/).")

    # Modulos Terraform em infra/modules/
    if "infra" in result["pastas_presentes"]:
        mods = _list_dir(owner, repo, "infra/modules", branch, token)
        mod_names = {i["name"] for i in mods if i.get("type") == "dir"}
        for mod in PROVA_ESTRUTURA["infra_modulos"]:
            (result["modulos_presentes"] if mod in mod_names
             else result["modulos_faltando"]).append(mod)
    else:
        result["modulos_faltando"] = list(PROVA_ESTRUTURA["infra_modulos"])

    # .tfstate versionado? (varredura leve na raiz e em infra/)
    if any(n.endswith(".tfstate") for n in nomes_raiz):
        result["tfstate_versionado"] = True
    else:
        infra_listing = _list_dir(owner, repo, "infra", branch, token)
        if any(i["name"].endswith(".tfstate") for i in infra_listing):
            result["tfstate_versionado"] = True
    if result["tfstate_versionado"]:
        result["observacoes"].append("ATENCAO: .tfstate versionado no repositorio.")

    return result


def collect_prova_sources(owner, repo, branch, token, max_bytes=60000):
    """Coleta arquivos-chave da prova (compose, relatorio, README, alguns .tf)."""
    h = gh_headers(token)
    blob = []
    total = 0

    def _append(path):
        nonlocal total
        if total >= max_bytes:
            return
        h_local = gh_headers(token)
        url = (f"{GITHUB_API}/repos/{owner}/{repo}/contents/"
               f"{urllib.parse.quote(path)}?ref={urllib.parse.quote(branch)}")
        data = get_json(url, h_local)
        if isinstance(data, dict) and data.get("download_url"):
            content = get_text(data["download_url"], h_local) or ""
            snippet = f"\n===== {path} =====\n{content}\n"
            if total + len(snippet) > max_bytes:
                snippet = snippet[: max_bytes - total]
            blob.append(snippet)
            total += len(snippet)

    for path in ("README.md", "docker-compose.yml", "relatorio.md",
                 "infra/main.tf", "infra/providers.tf", "infra/outputs.tf"):
        _append(path)
    return "".join(blob)


def find_default_branch_and_folder(owner, repo, aula, token):
    """
    Procura a pasta aula-XX no repo do portfolio, tentando o branch default
    e depois os demais branches. Retorna (branch, lista_de_arquivos) ou (None, None).
    """
    h = gh_headers(token)
    repo_info = get_json(f"{GITHUB_API}/repos/{owner}/{repo}", h)
    if not repo_info:
        return None, None
    candidates = [repo_info.get("default_branch", "main")]
    branches = get_json(f"{GITHUB_API}/repos/{owner}/{repo}/branches", h) or []
    for b in branches:
        if b["name"] not in candidates:
            candidates.append(b["name"])
    for branch in candidates:
        url = (f"{GITHUB_API}/repos/{owner}/{repo}/contents/"
               f"aula-{aula}?ref={urllib.parse.quote(branch)}")
        listing = get_json(url, h)
        if isinstance(listing, list) and listing:
            return branch, listing
    return None, None


def precheck(owner, repo, aula, token):
    """Retorna um dict com fatos objetivos verificaveis."""
    result = {
        "portfolio_encontrado": False,
        "pasta_aula_encontrada": False,
        "branch": None,
        "arquivos_presentes": [],
        "arquivos_faltando": [],
        "tem_condition_ou_deny": None,
        "tfstate_versionado": False,
        "plan_output_vazio": None,
        "codigo_na_branch_main": None,
        "observacoes": [],
    }
    h = gh_headers(token)
    repo_info = get_json(f"{GITHUB_API}/repos/{owner}/{repo}", h)
    if not repo_info:
        result["observacoes"].append(
            f"Repositorio de portfolio nao encontrado: {owner}/{repo}")
        return result
    result["portfolio_encontrado"] = True

    branch, listing = find_default_branch_and_folder(owner, repo, aula, token)
    if not listing:
        result["observacoes"].append(
            f"Pasta aula-{aula} nao encontrada em nenhum branch do portfolio.")
        return result
    result["pasta_aula_encontrada"] = True
    result["branch"] = branch
    result["codigo_na_branch_main"] = branch in ("main", "master")
    if not result["codigo_na_branch_main"]:
        result["observacoes"].append(
            f"Codigo publicado no branch '{branch}', nao na main/master do portfolio.")

    nomes = {item["name"]: item for item in listing}
    required = REQUIRED_BY_AULA.get(aula, [])
    for req in required:
        if req in nomes:
            result["arquivos_presentes"].append(req)
        else:
            result["arquivos_faltando"].append(req)

    # tfstate versionado?
    if any(n.endswith(".tfstate") for n in nomes):
        result["tfstate_versionado"] = True
        result["observacoes"].append("ATENCAO: .tfstate versionado no repositorio.")

    # plan output vazio?
    plan = nomes.get("terraform-plan-output.txt")
    if plan is not None:
        result["plan_output_vazio"] = (plan.get("size", 0) == 0)
        if result["plan_output_vazio"]:
            result["observacoes"].append("terraform-plan-output.txt esta vazio (0 bytes).")

    # baixa policies.tf (se houver) para checar Condition/Deny
    pol = nomes.get("policies.tf")
    if pol and pol.get("download_url"):
        txt = get_text(pol["download_url"], h) or ""
        result["tem_condition_ou_deny"] = bool(
            re.search(r"\bCondition\b", txt) or re.search(r'"?Deny"?', txt)
            or re.search(r"effect\s*=\s*\"Deny\"", txt, re.IGNORECASE))
        if not result["tem_condition_ou_deny"]:
            result["observacoes"].append(
                "Nenhuma Condition ou Deny explicito encontrado em policies.tf.")

    return result


# ---------------------------------------------------------------------------
# Pre-check para aulas com codigo entregue no proprio PR (ex.: aula 07)
# ---------------------------------------------------------------------------
def _pr_files_in_folder(files, aula):
    """Retorna os arquivos do PR dentro de entregas/aula-XX/ (qualquer RA)."""
    prefix = f"entregas/aula-{aula}/"
    return [f for f in files if f["filename"].startswith(prefix)]


def precheck_codigo_no_pr(files, aula):
    """
    Valida entregas que vem no proprio PR (sem portfolio).
    Confere presenca de arquivos obrigatorios, arquivo .js e node_modules.
    """
    spec = AULAS_CODIGO_NO_PR[aula]
    result = {
        "modo": "codigo_no_pr",
        "pasta_entrega_encontrada": False,
        "ra_pasta": None,
        "arquivos_presentes": [],
        "arquivos_faltando": [],
        "tem_js": False,
        "tem_processo_spec": False,
        "node_modules_versionado": False,
        "observacoes": [],
    }
    entregues = _pr_files_in_folder(files, aula)
    if not entregues:
        result["observacoes"].append(
            f"Nenhum arquivo encontrado em entregas/aula-{aula}/ no PR.")
        return result
    result["pasta_entrega_encontrada"] = True

    # tenta identificar o RA pela primeira subpasta
    m = re.search(rf"entregas/aula-{aula}/([^/]+)/", entregues[0]["filename"])
    if m:
        result["ra_pasta"] = m.group(1)

    basenames = [f["filename"].rsplit("/", 1)[-1] for f in entregues]

    for req in spec.get("obrigatorios", []):
        if req in basenames:
            result["arquivos_presentes"].append(req)
        else:
            result["arquivos_faltando"].append(req)

    result["tem_processo_spec"] = "processo-spec.md" in basenames
    result["tem_js"] = any(n.endswith(".js") for n in basenames)
    if spec.get("exige_js") and not result["tem_js"]:
        result["observacoes"].append("Nenhum arquivo .js encontrado (esperado server.js ou equivalente).")

    if any("/node_modules/" in f["filename"] for f in entregues):
        result["node_modules_versionado"] = True
        result["observacoes"].append("ATENCAO: node_modules/ versionado no PR (nao deveria).")

    if not result["tem_processo_spec"]:
        result["observacoes"].append("processo-spec.md ausente — e o item de maior peso do TF.")

    return result


def collect_pr_sources(repo, files, aula, token, max_bytes=60000):
    """Baixa o conteudo dos arquivos entregues no PR (aula de codigo-no-PR)."""
    h = gh_headers(token)
    entregues = _pr_files_in_folder(files, aula)
    blob = []
    total = 0
    for f in entregues:
        name = f["filename"].rsplit("/", 1)[-1]
        if "/node_modules/" in f["filename"]:
            continue
        if not (name.endswith(".js") or name.endswith(".md")
                or name in ("package.json", ".gitignore")):
            continue
        raw = f.get("raw_url")
        content = get_text(raw, h) if raw else None
        if content is None:
            continue
        snippet = f"\n===== {f['filename']} =====\n{content}\n"
        if total + len(snippet) > max_bytes:
            blob.append(snippet[: max_bytes - total])
            break
        blob.append(snippet)
        total += len(snippet)
    return "".join(blob)


def collect_tf_sources(owner, repo, aula, branch, token, max_bytes=60000):
    """Baixa o conteudo dos .tf, README e trecho do plan para mandar para a IA."""
    h = gh_headers(token)
    url = (f"{GITHUB_API}/repos/{owner}/{repo}/contents/"
           f"aula-{aula}?ref={urllib.parse.quote(branch)}")
    listing = get_json(url, h) or []
    blob = []
    total = 0
    for item in listing:
        name = item["name"]
        if not (name.endswith(".tf") or name in ("README.md",
                                                 "terraform-plan-output.txt",
                                                 ".gitignore")):
            continue
        dl = item.get("download_url")
        if not dl:
            continue
        content = get_text(dl, h) or ""
        if name == "terraform-plan-output.txt":
            content = content[:4000]  # so um trecho do plan
        snippet = f"\n===== {name} =====\n{content}\n"
        if total + len(snippet) > max_bytes:
            snippet = snippet[: max_bytes - total]
            blob.append(snippet)
            break
        blob.append(snippet)
        total += len(snippet)
    return "".join(blob)


# ---------------------------------------------------------------------------
# Analise via Amazon Bedrock
# ---------------------------------------------------------------------------
def avaliar_com_bedrock(criterios, entrega_md, tf_sources, precheck_data,
                        aula, model_id, region, modo="portfolio"):
    import boto3

    client = boto3.client("bedrock-runtime", region_name=region)

    if modo == "codigo_no_pr":
        system = (
            "Voce e um professor de DevOps avaliando um Trabalho de Fixacao (TF) conceitual "
            "sobre decomposicao de problemas e Spec-Driven Development (aula sem AWS). "
            "O codigo do aluno vem no proprio PR (Node.js/Express). Avalie SOMENTE com base "
            "nos criterios fornecidos e nos arquivos reais. Atribua uma nota de 0 a 1,5. "
            "O item de MAIOR peso e o 'processo-spec.md' (como o aluno decompos o problema, "
            "guiou a IA e validou cada parte) — avalie sua completude e honestidade. "
            "Verifique tambem se as rotas minimas existem no codigo (cadastrar/listar salas, "
            "criar reserva com bloqueio de conflito de horario, cancelar e listar reservas). "
            "Se o 'processo-spec.md' estiver ausente ou generico/copiado, reduza muito a nota. "
            "Produza um parecer de APROVACAO ou REPROVACAO em portugues, em markdown, pronto "
            "para o review do PR."
        )
        user = f"""## Criterios do TF (aula-{aula}/TF.md)
{criterios or "(criterios nao encontrados no repositorio)"}

## Resultado do pre-check deterministico
{json.dumps(precheck_data, ensure_ascii=False, indent=2)}

## Arquivos entregues no PR (codigo Node.js + processo-spec.md)
{tf_sources or "(nenhum arquivo acessivel no PR)"}

Gere o parecer final com: nota (X / 1,5), tabela de criterios (processo-spec.md,
decomposicao, codigo funcional/rotas, validacao por etapas, reflexao), pontos fortes,
ressalvas e um bloco de texto pronto para o review do PR."""
    elif modo == "prova":
        system = (
            "Voce e um professor de DevOps avaliando a PROVA DO 1o BIMESTRE (aulas 01 a 07). "
            "O aluno entrega a API de Reservas (Node.js + PostgreSQL) com Docker, Docker Compose "
            "e infraestrutura AWS modularizada (VPC, Security Group, EC2, RDS) com remote state (S3+DynamoDB), "
            "usando AWS Academy Learner Lab (LabRole/LabInstanceProfile, sem criar IAM proprio). "
            "Avalie SOMENTE com base nos criterios fornecidos e nos arquivos reais do repositorio. "
            "Atribua uma nota de 0 a 10 (a prova vale 10 pontos). "
            "Os componentes 'execucao no AWS Academy' e a nota fina do 'relatorio' dependem de "
            "conferencia do professor — avalie o que for verificavel pelo repositorio (estrutura, "
            "Dockerfile, docker-compose, modulos Terraform, CRUD, remote state, .gitignore) e "
            "marque o resto como pendente de conferencia. "
            "Se o repositorio nao existir/estiver incompleto, reduza a nota proporcionalmente. "
            "Produza um parecer em portugues, em markdown, pronto para o review do PR."
        )
        user = f"""## Criterios da Prova (provas/prova-primeiro-bimestre.md)
{criterios or "(criterios nao encontrados no repositorio)"}

## Resultado do pre-check deterministico
{json.dumps(precheck_data, ensure_ascii=False, indent=2)}

## entrega.md do PR
{entrega_md or "(entrega.md nao encontrado)"}

## Arquivos-chave do repositorio da prova (README, compose, relatorio, alguns .tf)
{tf_sources or "(nenhum arquivo acessivel no repositorio da prova)"}

Gere o parecer final com: nota (X / 10), tabela de criterios (Git+Docker, Compose,
Terraform+Modulos+Remote State, uso de IA, relatorio), pontos fortes, ressalvas e um
bloco de texto pronto para o review do PR. Marque 'execucao no AWS Academy' como
pendente de conferencia do professor."""
    else:
        system = (
            "Voce e um professor de DevOps avaliando um Trabalho de Fixacao (TF). "
            "Avalie SOMENTE com base nos criterios fornecidos e no codigo real do aluno. "
            "Atribua uma nota de 0 a 1,5 (proporcional aos criterios verificaveis pelo PR). "
            "O componente 'AWS Academy' (geralmente 20%) NAO e verificavel pelo PR: "
            "marque-o como pendente de conferencia do professor e nao o inclua na nota automatica. "
            "Seja direto, aponte pontos fortes e ressalvas concretas com base no codigo. "
            "Produza um parecer de APROVACAO ou REPROVACAO pronto para colar no review do PR, "
            "em portugues, em markdown. Se o codigo do portfolio nao existir/estiver ausente, "
            "REPROVE por entrega nao verificavel."
        )
        user = f"""## Criterios do TF (aula-{aula}/TF.md)
{criterios or "(criterios nao encontrados no repositorio)"}

## Resultado do pre-check deterministico
{json.dumps(precheck_data, ensure_ascii=False, indent=2)}

## entrega.md do PR
{entrega_md or "(entrega.md nao encontrado)"}

## Codigo do portfolio (arquivos .tf, README, trecho do plan)
{tf_sources or "(nenhum arquivo de codigo acessivel no portfolio)"}

Gere o parecer final com: nota (X / 1,5), tabela de criterios, pontos fortes,
ressalvas e um bloco de texto pronto para o review do PR."""

    body = {
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 4096,
        "system": system,
        "messages": [{"role": "user", "content": [{"type": "text", "text": user}]}],
    }
    resp = client.invoke_model(modelId=model_id, body=json.dumps(body))
    payload = json.loads(resp["body"].read())
    return "".join(part.get("text", "") for part in payload.get("content", []))


# ---------------------------------------------------------------------------
# Parecer deterministico (fallback quando a IA esta desligada)
# ---------------------------------------------------------------------------
def parecer_deterministico(precheck_data, aula, ra):
    linhas = [f"### Pre-check automatico — Aula {aula} (RA: {ra or 'n/d'})", ""]
    if not precheck_data["portfolio_encontrado"]:
        linhas.append("- ❌ Repositorio de portfolio nao encontrado pelo link do `entrega.md`.")
        linhas.append("\n**Resultado:** entrega nao verificavel. Publique o codigo e reabra.")
        return "\n".join(linhas)
    if not precheck_data["pasta_aula_encontrada"]:
        linhas.append(f"- ❌ Pasta `aula-{aula}` nao encontrada no portfolio (nenhum branch).")
        linhas.append("\n**Resultado:** entrega nao verificavel. Publique o codigo.")
        return "\n".join(linhas)
    linhas.append(f"- ✅ Portfolio e pasta `aula-{aula}` encontrados (branch `{precheck_data['branch']}`).")
    if precheck_data["arquivos_presentes"]:
        linhas.append(f"- ✅ Arquivos presentes: {', '.join(precheck_data['arquivos_presentes'])}")
    if precheck_data["arquivos_faltando"]:
        linhas.append(f"- ⚠️ Arquivos faltando: {', '.join(precheck_data['arquivos_faltando'])}")
    if precheck_data["tem_condition_ou_deny"] is False:
        linhas.append("- ⚠️ Nenhuma `Condition` ou `Deny` explicito em `policies.tf`.")
    elif precheck_data["tem_condition_ou_deny"]:
        linhas.append("- ✅ `Condition`/`Deny` presente em `policies.tf`.")
    if precheck_data["tfstate_versionado"]:
        linhas.append("- ❌ `.tfstate` versionado (nao deveria estar no repo).")
    if precheck_data["plan_output_vazio"]:
        linhas.append("- ⚠️ `terraform-plan-output.txt` vazio.")
    if precheck_data["codigo_na_branch_main"] is False:
        linhas.append(f"- ⚠️ Codigo publicado fora da main do portfolio (branch `{precheck_data['branch']}`).")
    linhas.append("\n> ⚠️ Componente **AWS Academy** deve ser conferido pelo professor (nao verificavel pelo PR).")
    return "\n".join(linhas)


def parecer_deterministico_codigo_no_pr(pre, aula, ra):
    """Parecer de pre-check para aulas em que o codigo vem no proprio PR."""
    linhas = [f"### Pre-check automatico — Aula {aula} (RA: {ra or pre.get('ra_pasta') or 'n/d'})", ""]
    if not pre["pasta_entrega_encontrada"]:
        linhas.append(f"- ❌ Nenhum arquivo encontrado em `entregas/aula-{aula}/SEU-RA/` no PR.")
        linhas.append("\n**Resultado:** entrega nao verificavel. Adicione o codigo e o `processo-spec.md` na pasta da sua entrega.")
        return "\n".join(linhas)
    linhas.append(f"- ✅ Pasta de entrega encontrada (`entregas/aula-{aula}/{pre.get('ra_pasta') or 'RA'}/`).")
    if pre["arquivos_presentes"]:
        linhas.append(f"- ✅ Arquivos presentes: {', '.join(pre['arquivos_presentes'])}")
    if pre["arquivos_faltando"]:
        linhas.append(f"- ⚠️ Arquivos faltando: {', '.join(pre['arquivos_faltando'])}")
    if pre["tem_processo_spec"]:
        linhas.append("- ✅ `processo-spec.md` presente (item de maior peso).")
    else:
        linhas.append("- ❌ `processo-spec.md` ausente (item de maior peso do TF).")
    if pre["tem_js"]:
        linhas.append("- ✅ Arquivo `.js` (código do projeto) presente.")
    else:
        linhas.append("- ⚠️ Nenhum arquivo `.js` encontrado.")
    if pre["node_modules_versionado"]:
        linhas.append("- ❌ `node_modules/` versionado (adicione ao `.gitignore`).")
    linhas.append("\n> O parecer detalhado (qualidade do `processo-spec.md`, rotas e decomposição) é gerado pela análise por IA ou revisado pelo professor.")
    return "\n".join(linhas)


def parecer_deterministico_prova(pre, ra):
    """Pre-check para a Prova do 1o Bimestre (repositorio proprio do aluno)."""
    linhas = [f"### Pre-check automatico — Prova do 1º Bimestre (RA: {ra or 'n/d'})", ""]
    if not pre["repo_encontrado"]:
        linhas.append("- ❌ Repositorio `prova-primeiro-bimestre-devops` nao encontrado pelo link do `entrega.md`.")
        linhas.append("\n**Resultado:** entrega nao verificavel. Publique o repositorio (publico) e reabra.")
        return "\n".join(linhas)
    linhas.append(f"- ✅ Repositorio da prova encontrado (branch `{pre['branch']}`).")
    if pre["raiz_presentes"]:
        linhas.append(f"- ✅ Arquivos na raiz: {', '.join(pre['raiz_presentes'])}")
    if pre["raiz_faltando"]:
        linhas.append(f"- ⚠️ Faltando na raiz: {', '.join(pre['raiz_faltando'])}")
    if pre["pastas_presentes"]:
        linhas.append(f"- ✅ Pastas presentes: {', '.join(pre['pastas_presentes'])}")
    if pre["pastas_faltando"]:
        linhas.append(f"- ⚠️ Pastas faltando: {', '.join(pre['pastas_faltando'])}")
    if pre["tem_dockerfile"]:
        linhas.append("- ✅ Dockerfile da API presente.")
    else:
        linhas.append("- ⚠️ Dockerfile da API nao encontrado (esperado em `app/`).")
    if pre["modulos_presentes"]:
        linhas.append(f"- ✅ Modulos Terraform: {', '.join(pre['modulos_presentes'])}")
    if pre["modulos_faltando"]:
        linhas.append(f"- ⚠️ Modulos faltando em `infra/modules/`: {', '.join(pre['modulos_faltando'])}")
    if pre["tfstate_versionado"]:
        linhas.append("- ❌ `.tfstate` versionado (nao deveria estar no repo).")
    linhas.append("\n> ⚠️ Componentes **AWS Academy** (execucao no Learner Lab) e **relatorio** sao conferidos pelo professor. O parecer detalhado e gerado pela analise por IA ou pela revisao manual.")
    return "\n".join(linhas)


# ---------------------------------------------------------------------------
# Comentar no PR
# ---------------------------------------------------------------------------
def upsert_comment(repo, pr_number, token, body):
    h = gh_headers(token)
    body_full = f"{BOT_MARKER}\n{body}"
    comments = get_json(
        f"{GITHUB_API}/repos/{repo}/issues/{pr_number}/comments", h) or []
    for c in comments:
        if BOT_MARKER in (c.get("body") or ""):
            requests.patch(
                f"{GITHUB_API}/repos/{repo}/issues/comments/{c['id']}",
                headers=h, json={"body": body_full}, timeout=30).raise_for_status()
            return
    requests.post(
        f"{GITHUB_API}/repos/{repo}/issues/{pr_number}/comments",
        headers=h, json={"body": body_full}, timeout=30).raise_for_status()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    token = os.environ["GITHUB_TOKEN"]
    repo = os.environ["GITHUB_REPOSITORY"]
    pr_number = os.environ["PR_NUMBER"]
    use_bedrock = os.environ.get("USE_BEDROCK", "true").lower() == "true"

    pr, files = fetch_pr(repo, pr_number, token)
    title = pr.get("title", "")
    base_sha = pr["head"]["sha"]

    aula = detect_aula(title)
    ra = detect_ra(title)
    if not aula:
        upsert_comment(repo, pr_number, token,
                       "Nao consegui identificar a entrega pelo titulo do PR. "
                       "Use `[Aula 0X] RA: NNN - Nome` ou, para a prova, "
                       "`[Prova Primeiro Bimestre] RA: NNN - Nome`.")
        return

    criterios = read_local_criteria(aula)
    model_id = os.environ.get("BEDROCK_MODEL_ID",
                              "anthropic.claude-3-5-sonnet-20240620-v1:0")
    region = os.environ.get("AWS_REGION", "us-east-1")

    # --- Caso 1: aula conceitual com codigo entregue no proprio PR (ex.: aula 07) ---
    if aula in AULAS_CODIGO_NO_PR:
        pre = precheck_codigo_no_pr(files, aula)
        corpo = None
        if use_bedrock and pre["pasta_entrega_encontrada"]:
            try:
                pr_sources = collect_pr_sources(repo, files, aula, token)
                corpo = avaliar_com_bedrock(
                    criterios, None, pr_sources, pre, aula,
                    model_id, region, modo="codigo_no_pr")
            except Exception as exc:
                corpo = (parecer_deterministico_codigo_no_pr(pre, aula, ra) +
                         f"\n\n_(analise por IA indisponivel: {exc})_")
        else:
            corpo = parecer_deterministico_codigo_no_pr(pre, aula, ra)

        rodape = ("\n\n---\n_Avaliacao automatica gerada por GitHub Actions. "
                  "A nota final e revisada pelo professor._")
        upsert_comment(repo, pr_number, token, corpo + rodape)
        print("Comentario publicado com sucesso (modo codigo-no-PR).")
        return

    # --- Caso 2: Prova do 1o Bimestre (repositorio proprio prova-primeiro-bimestre-devops) ---
    if aula == "provaPrimeiroBi":
        _, entrega_md = find_entrega_md(repo, files, base_sha, token)
        portfolio = extract_portfolio(entrega_md, aula)
        if not portfolio:
            pre = {"repo_encontrado": False,
                   "observacoes": ["Link do repositorio da prova nao encontrado no entrega.md."]}
            upsert_comment(repo, pr_number, token,
                           parecer_deterministico_prova(pre, ra))
            return
        owner, repo_pf = portfolio
        pre = precheck_prova(owner, repo_pf, token)
        corpo = None
        if use_bedrock and pre["repo_encontrado"]:
            try:
                prova_sources = collect_prova_sources(
                    owner, repo_pf, pre["branch"], token)
                corpo = avaliar_com_bedrock(
                    criterios, entrega_md, prova_sources, pre, aula,
                    model_id, region, modo="prova")
            except Exception as exc:
                corpo = (parecer_deterministico_prova(pre, ra) +
                         f"\n\n_(analise por IA indisponivel: {exc})_")
        else:
            corpo = parecer_deterministico_prova(pre, ra)
        rodape = ("\n\n---\n_Avaliacao automatica gerada por GitHub Actions. "
                  "A nota final e revisada pelo professor, incluindo a execucao no AWS Academy._")
        upsert_comment(repo, pr_number, token, corpo + rodape)
        print("Comentario publicado com sucesso (modo prova).")
        return

    # --- Caso 3: aulas com codigo no repositorio de portfolio (padrao) ---
    _, entrega_md = find_entrega_md(repo, files, base_sha, token)
    portfolio = extract_portfolio(entrega_md, aula)

    if not portfolio:
        pre = {"portfolio_encontrado": False, "pasta_aula_encontrada": False,
               "observacoes": ["Link do portfolio nao encontrado no entrega.md."]}
        upsert_comment(repo, pr_number, token,
                       parecer_deterministico(pre, aula, ra))
        return

    owner, repo_pf = portfolio
    pre = precheck(owner, repo_pf, aula, token)

    corpo = None
    if use_bedrock and pre["pasta_aula_encontrada"]:
        try:
            tf_sources = collect_tf_sources(
                owner, repo_pf, aula, pre["branch"], token)
            corpo = avaliar_com_bedrock(
                criterios, entrega_md, tf_sources, pre, aula,
                model_id, region)
        except Exception as exc:  # nao derruba o workflow; cai no deterministico
            corpo = (parecer_deterministico(pre, aula, ra) +
                     f"\n\n_(analise por IA indisponivel: {exc})_")
    else:
        corpo = parecer_deterministico(pre, aula, ra)

    rodape = ("\n\n---\n_Avaliacao automatica gerada por GitHub Actions. "
              "A nota final e revisada pelo professor, incluindo o componente AWS Academy._")
    upsert_comment(repo, pr_number, token, corpo + rodape)
    print("Comentario publicado com sucesso.")


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"Falha na avaliacao: {exc}", file=sys.stderr)
        sys.exit(1)
