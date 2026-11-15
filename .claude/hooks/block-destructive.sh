#!/usr/bin/env bash
# Hook: PreToolUse — Bloqueia comandos destrutivos antes de executar
# Recebe JSON via stdin: {"tool_name": "Bash", "tool_input": {"command": "..."}}

INPUT=$(cat)

TOOL=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_name', ''))
except:
    print('')
" 2>/dev/null)

# Só inspeciona o tool Bash
[[ "$TOOL" != "Bash" ]] && exit 0

COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', ''))
except:
    print('')
" 2>/dev/null)

# Padrões bloqueados
BLOCKED=(
    "rm -rf"
    "rm -fr"
    "git push --force"
    "git push -f "
    "git reset --hard"
    "DROP TABLE"
    "DROP DATABASE"
    "TRUNCATE TABLE"
    "chmod -R 777"
    "mkfs"
    "dd if="
)

for pattern in "${BLOCKED[@]}"; do
    if echo "$COMMAND" | grep -qi "$pattern"; then
        echo "[BLOQUEADO] Comando perigoso detectado: '$pattern'"
        echo "Se realmente necessário, execute manualmente no terminal."
        exit 2
    fi
done

# Leitura de arquivos de segredo via shell (permissions.deny cobre só o tool Read)
SECRET_RE='(cat|less|more|head|tail|grep|rg|sed|awk|cp|mv|base64|xxd|strings|source|\.)[[:space:]]+[^|;&]*(\.env([^a-zA-Z0-9_-]|$)|\.env\.[a-zA-Z0-9_.-]+|\.pem([^a-zA-Z0-9_]|$)|id_rsa|id_ed25519)'
if echo "$COMMAND" | grep -Eq "$SECRET_RE" && ! echo "$COMMAND" | grep -Eq '\.env\.(example|sample|template)'; then
    echo "[BLOQUEADO] Leitura de arquivo de segredo (.env, chave, pem) pelo shell."
    echo "Peça ao usuário o valor necessário."
    exit 2
fi

exit 0
