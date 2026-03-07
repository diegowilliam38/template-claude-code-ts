#!/usr/bin/env bash
# adopt.sh — adiciona a estrutura Claude Code a um projeto existente
#
# USO (requer gh CLI autenticado — repo privado):
#   gh repo clone ecodelearn/template-claude-code-ts /tmp/cc-template -- --depth=1 --quiet \
#     && bash /tmp/cc-template/adopt.sh; rm -rf /tmp/cc-template
#
#   ou, com o repo já clonado localmente:
#   bash /caminho/para/template-claude-code-ts/adopt.sh

set -euo pipefail

TEMPLATE_REPO="ecodelearn/template-claude-code-ts"
TEMP_DIR=$(mktemp -d)
TARGET_DIR="${PWD}"

# --- Cores ---
info()  { echo -e "\033[34m[INFO]\033[0m $*"; }
ok()    { echo -e "\033[32m[ OK ]\033[0m $*"; }
warn()  { echo -e "\033[33m[WARN]\033[0m $*"; }
erro()  { echo -e "\033[31m[ERRO]\033[0m $*" >&2; exit 1; }

# --- Validações ---
[[ ! -d "${TARGET_DIR}/.git" ]] && erro "Execute este script na raiz de um repositório git."
command -v gh &>/dev/null || erro "GitHub CLI (gh) não encontrado. Instale em: https://cli.github.com"

info "Projeto detectado: ${TARGET_DIR}"
info "Baixando estrutura do template..."

# Clone silencioso do template
gh repo clone "$TEMPLATE_REPO" "$TEMP_DIR" -- --depth=1 --quiet 2>/dev/null \
  || erro "Falha ao clonar o template. Verifique acesso ao repo: ${TEMPLATE_REPO}"

# --- Arquivos a copiar ---
# Só copia a estrutura .claude/ e o CLAUDE.md
# NÃO sobrescreve: README.md, docs/, QUICKSTART.md — esses são do template, não do projeto

if [[ -d "${TARGET_DIR}/.claude" ]]; then
    warn ".claude/ já existe neste projeto."
    read -rp "Deseja sobrescrever? Arquivos existentes serão perdidos. [s/N] " resposta
    [[ "${resposta,,}" != "s" ]] && { info "Operação cancelada."; rm -rf "$TEMP_DIR"; exit 0; }
fi

cp -r "${TEMP_DIR}/.claude" "${TARGET_DIR}/"
ok ".claude/ copiado"

if [[ -f "${TARGET_DIR}/CLAUDE.md" ]]; then
    warn "CLAUDE.md já existe — mantendo o existente."
else
    cp "${TEMP_DIR}/CLAUDE.md" "${TARGET_DIR}/"
    ok "CLAUDE.md copiado"
fi

# Copia .gitignore só se não existir
if [[ ! -f "${TARGET_DIR}/.gitignore" ]]; then
    cp "${TEMP_DIR}/.gitignore" "${TARGET_DIR}/"
    ok ".gitignore copiado"
fi

rm -rf "$TEMP_DIR"

# --- Permissões dos hooks ---
chmod +x "${TARGET_DIR}/.claude/hooks/"*.sh 2>/dev/null || true

# --- Resultado ---
echo ""
ok "Estrutura Claude Code adicionada ao projeto."
echo ""
echo "  Próximo passo:"
echo "  1. Abra o Claude Code na raiz do projeto: claude"
echo "  2. Execute: /project-adopt"
echo ""
echo "  O agente vai mapear o codebase existente e configurar a memória"
echo "  com as convenções e stack que já estão no código."
echo ""
