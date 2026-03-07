#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT_DIR"
TOOL_NAME="${1:-gemini}"

echo "[smoke] build"
npm run build >/dev/null

NPM_CACHE_DIR="$ROOT_DIR/.npm-cache-smoke"
mkdir -p "$NPM_CACHE_DIR"
export npm_config_cache="$NPM_CACHE_DIR"

echo "[smoke] pack"
PKG_FILE=$(npm pack --silent)
TARBALL_PATH="$ROOT_DIR/$PKG_FILE"

cleanup() {
  rm -f "$TARBALL_PATH"
  rm -rf "$NPM_CACHE_DIR"
}
trap cleanup EXIT

echo "[smoke] npx --help"
npx --yes --package "$TARBALL_PATH" adopt --help >/dev/null

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"; cleanup' EXIT

PROJECT_DIR="$TMP_DIR/project"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"
git init -q

echo "[smoke] adopt in temp git repo"
npx --yes --package "$TARBALL_PATH" adopt \
  --tool "$TOOL_NAME" \
  --source "$ROOT_DIR" \
  --target "$PROJECT_DIR" \
  --yes >/dev/null

if [[ "$TOOL_NAME" == "gemini" || "$TOOL_NAME" == "antigravity" ]]; then
  [[ -f "$PROJECT_DIR/GEMINI.md" ]] || { echo "[smoke] FAIL: GEMINI.md not copied"; exit 1; }
  [[ -f "$PROJECT_DIR/AGENTS.md" ]] || { echo "[smoke] FAIL: AGENTS.md not copied"; exit 1; }
  [[ -d "$PROJECT_DIR/.gemini/skills" ]] || { echo "[smoke] FAIL: .gemini/skills not created"; exit 1; }
  find "$PROJECT_DIR/.gemini/skills" -type f -name 'SKILL.md' | grep -q . || {
    echo "[smoke] FAIL: no SKILL.md found in .gemini/skills"
    exit 1
  }
else
  [[ -d "$PROJECT_DIR/.claude" ]] || { echo "[smoke] FAIL: .claude not copied"; exit 1; }
  [[ -f "$PROJECT_DIR/CLAUDE.md" ]] || { echo "[smoke] FAIL: CLAUDE.md not copied"; exit 1; }
  [[ -f "$PROJECT_DIR/.claude/hooks/auto-format.sh" ]] || { echo "[smoke] FAIL: auto-format hook missing"; exit 1; }
  [[ -f "$PROJECT_DIR/.claude/hooks/block-destructive.sh" ]] || { echo "[smoke] FAIL: block-destructive hook missing"; exit 1; }
  [[ -f "$PROJECT_DIR/.claude/hooks/session-end-context.sh" ]] || { echo "[smoke] FAIL: session-end hook missing"; exit 1; }
fi
[[ -f "$PROJECT_DIR/.gitignore" ]] || { echo "[smoke] FAIL: .gitignore not copied"; exit 1; }

if [[ "$TOOL_NAME" == "gemini" || "$TOOL_NAME" == "antigravity" ]]; then
  echo "MANTER ESTE GEMINI" > "$PROJECT_DIR/GEMINI.md"
else
  echo "MANTER ESTE CLAUDE" > "$PROJECT_DIR/CLAUDE.md"
fi

echo "[smoke] idempotency check"
npx --yes --package "$TARBALL_PATH" adopt \
  --tool "$TOOL_NAME" \
  --source "$ROOT_DIR" \
  --target "$PROJECT_DIR" \
  --yes >/dev/null

if [[ "$TOOL_NAME" == "gemini" || "$TOOL_NAME" == "antigravity" ]]; then
  grep -q "MANTER ESTE GEMINI" "$PROJECT_DIR/GEMINI.md" || {
    echo "[smoke] FAIL: existing GEMINI.md was overwritten"
    exit 1
  }
else
  grep -q "MANTER ESTE CLAUDE" "$PROJECT_DIR/CLAUDE.md" || {
    echo "[smoke] FAIL: existing CLAUDE.md was overwritten"
    exit 1
  }
fi

echo "[smoke] PASS"
