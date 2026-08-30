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
    """Extrai o numero da aula do titulo do PR. Ex.: '[Aula 03] ...' -> '03'."""
    m = re.search(r"aula[\s\-_]*0*(\d+)", title, re.IGNORECASE)
    if m:
        return f"{int(m.group(1)):02d}"
    return None


def detect_ra(title):
    m = re.search(r"RA[:\s]*([0-9]{4,})", title, re.IGNORECASE)
    return m.group(1) if m else None


def read_local_criteria(aula):
    """Le aula-XX/TF.md do repositorio da disciplina (checkout local)."""
    path = os.path.join(f"aula-{aula}", "TF.md")
    if os.path.exists(path):
        with open(path, encoding="utf-8") as fh:
            return fh.read()
    return None


def extract_portfolio(entrega_md):
    """Extrai owner/repo do link do portfolio dentro do entrega.md."""
    if not entrega_md:
        return None
    m = re.search(r"github\.com/([\w.-]+)/(unifaat-devops-portfolio)", entrega_md)
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
    "02": ["docker-compose.yml", "Dockerfile", "app.js", "package.json",
           ".gitignore", "ia-analise.md"],
}


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
                        aula, model_id, region):
    import boto3

    client = boto3.client("bedrock-runtime", region_name=region)

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
                       "Nao consegui identificar a aula pelo titulo do PR. "
                       "Use o formato `[Aula 0X] RA: NNN - Nome`.")
        return

    _, entrega_md = find_entrega_md(repo, files, base_sha, token)
    criterios = read_local_criteria(aula)
    portfolio = extract_portfolio(entrega_md)

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
                os.environ.get("BEDROCK_MODEL_ID",
                               "anthropic.claude-3-5-sonnet-20240620-v1:0"),
                os.environ.get("AWS_REGION", "us-east-1"))
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
