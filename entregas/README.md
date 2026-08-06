# 📬 Entregas de Trabalhos de Fixação (TF)

Este diretório contém as entregas dos alunos para os **Trabalhos de Fixação (TF)** de cada aula.

---

## 📋 Como Entregar seu TF

### Passo a Passo

1. **Fork** — Faça um fork deste repositório para sua conta pessoal no GitHub
2. **Clone** — Clone o fork para sua máquina local:
   ```bash
   git clone https://github.com/SEU-USUARIO/unifaat-2026-2-devops.git
   ```
3. **Branch** — Crie uma branch com o padrão `aula-XX/RA-XXXXX`:
   ```bash
   git checkout -b aula-07/RA-12345
   ```
4. **Pasta** — Crie sua pasta de entrega dentro de `entregas/aula-XX/RA/`:
   ```bash
   mkdir -p entregas/aula-07/12345/
   ```
5. **Arquivos** — Adicione os arquivos solicitados no enunciado do TF
6. **Commit** — Faça commit com uma mensagem descritiva:
   ```bash
   git add entregas/aula-07/12345/
   git commit -m "TF Aula 07: Configuração Terraform VPC e EC2"
   ```
7. **Push** — Envie para seu fork:
   ```bash
   git push origin aula-07/RA-12345
   ```
8. **Pull Request** — Abra um PR do seu fork para o repositório principal

---

## 🏷️ Convenção de Nome do PR

O título do Pull Request deve seguir o formato:

```
[Aula XX] RA: XXXXX - Nome Completo
```

### Exemplos:
- `[Aula 07] RA: 12345 - João da Silva`
- `[Aula 11] RA: 67890 - Maria Santos`

---

## 🚫 Regras — Arquivos Proibidos

Os seguintes arquivos **NÃO devem ser commitados** em hipótese alguma:

| Arquivo/Pasta | Motivo |
|---------------|--------|
| `*.tfstate` / `*.tfstate.backup` | Contém estado da infraestrutura com dados sensíveis |
| `.env` | Contém variáveis de ambiente e secrets |
| `node_modules/` | Dependências instaláveis via `npm install` |
| `*.pem` | Chaves privadas de acesso SSH/AWS |

> ⚠️ PRs contendo qualquer um desses arquivos serão **rejeitados automaticamente**.

Dica: Utilize o `.gitignore` para garantir que esses arquivos não sejam rastreados:

```gitignore
*.tfstate
*.tfstate.backup
.env
node_modules/
*.pem
```

---

## 📁 Estrutura de Pastas de Entrega

```
entregas/
├── aula-01/
│   ├── 12345/          ← RA do aluno
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── README.md
│   └── 67890/
│       ├── main.tf
│       └── outputs.tf
├── aula-02/
│   └── ...
├── ...
└── aula-15/
    └── ...
```

Cada aluno cria uma pasta com seu **RA** (Registro Acadêmico) dentro da pasta da aula correspondente.

---

## ❓ Dúvidas

- Verifique o enunciado do TF na pasta da aula (`TF.md`)
- Em caso de problemas com o PR, entre em contato com o professor
- PRs devem ser abertos **antes do prazo** indicado no enunciado
