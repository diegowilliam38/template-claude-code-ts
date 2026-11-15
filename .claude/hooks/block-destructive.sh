#!/usr/bin/env bash
# Hook: PreToolUse — Bloqueia comandos destrutivos antes de executar
# Recebe JSON via stdin: {"tool_name": "Bash", "tool_input": {"command": "..."}}

INPUT=$(cat)

# Lê o comando com jq, depois python3. Sem nenhum dos dois, compara os padrões
# contra o JSON bruto em vez de liberar tudo.
if command -v jq &>/dev/null; then
    TOOL=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
    COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
elif command -v python3 &>/dev/null; then
    TOOL=$(printf '%s' "$INPUT" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_name",""))' 2>/dev/null)
    COMMAND=$(printf '%s' "$INPUT" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null)
else
    TOOL="Bash"
    COMMAND="$INPUT"
fi

# Só inspeciona o tool Bash
[[ "$TOOL" != "Bash" ]] && exit 0
[[ -z "$COMMAND" ]] && exit 0

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
    if printf '%s' "$COMMAND" | grep -qiF -- "$pattern"; then
        echo "[BLOQUEADO] Comando perigoso detectado: '$pattern'" >&2
        echo "Se realmente necessário, execute manualmente no terminal." >&2
        exit 2
    fi
done

# Leitura de arquivos de segredo via shell (permissions.deny cobre só o tool Read).
# Proteção contra descuido, não barreira de segurança: interpretadores, variáveis
# e cópias ainda conseguem ler esses arquivos.
CHECK=$(printf '%s' "$COMMAND" | sed -E 's/\.env\.(example|sample|template)//g; s/id_(rsa|ed25519)[A-Za-z0-9_-]*\.pub//g')
READERS='(cat|less|more|head|tail|grep|rg|sed|awk|base64|xxd|strings|source|\.)'
SEP="[[:space:]/\"'=<]"
END="(\$|[[:space:]\"'|;&>)\\])"
SECRET="(\.env(\.[A-Za-z0-9_.-]+)?${END}|[A-Za-z0-9_.-]*\.pem${END}|id_rsa|id_ed25519)"
if printf '%s' "$CHECK" | grep -Eq "(^|[[:space:];&|(\"])${READERS}[[:space:]]+([^|;&]*${SEP})?${SECRET}"; then
    echo "[BLOQUEADO] Leitura de arquivo de segredo (.env, chave, pem) pelo shell." >&2
    echo "Peça ao usuário o valor necessário." >&2
    exit 2
fi

exit 0
