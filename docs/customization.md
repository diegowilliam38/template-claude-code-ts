# Customização — adaptando o template ao seu projeto

## Adicionando uma skill

Crie um diretório com um `SKILL.md` como entrypoint:

```bash
mkdir -p .claude/skills/minha-skill
```

`SKILL.md` com frontmatter obrigatório:

```markdown
---
name: minha-skill
description: O que esta skill faz e quando Claude deve usá-la. Seja específico.
disable-model-invocation: true
argument-hint: "[argumento-opcional]"
---

# Skill: minha-skill

## Quando usar
[Descreva a situação exata]

## Passos
1. [Passo 1]
2. [Passo 2]

## Saída esperada
[Mostre um exemplo concreto]
```

Adicione uma linha no `.claude/skills/README.md`:
```markdown
| `/minha-skill` | `minha-skill/` | [quando usar — 1 frase] |
```

**Decisões de frontmatter:**

| Quero... | Use |
|----------|-----|
| Só eu posso executar (deploy, commit, sensível) | `disable-model-invocation: true` |
| Claude também pode disparar automaticamente | omita `disable-model-invocation` |
| Skill roda em contexto isolado | `context: fork` |
| Restringir ferramentas disponíveis | `allowed-tools: Read, Grep` |
| Usar modelo específico | `model: haiku` |

**Arquivos de suporte** — mantenha o SKILL.md focado:

```
.claude/skills/deploy/
├── SKILL.md            ← visão geral + "veja checklist.md para detalhes"
├── checklist.md        ← checklist detalhado
└── scripts/
    └── pre-deploy.sh   ← Claude pode executar isso
```

Referencie os arquivos de suporte no SKILL.md para que Claude saiba que existem.

Referência: https://code.claude.com/docs/en/skills

---

## Aplicando o pipeline de 7 estágios

Para elevar consistência em features maiores, use o fluxo completo de engenharia:

1. Requisitos
2. Design técnico
3. Planejamento
4. Build
5. Review
6. Deploy
7. Monitoramento

Use [docs/dev-pipeline.md](dev-pipeline.md) como playbook e mantenha a spec atualizada durante todo o ciclo.

---

## Adicionando regras por caminho (rules/)

Rules em `.claude/rules/` carregam automaticamente quando Claude trabalha com arquivos correspondentes. Não consomem tokens quando irrelevantes.

Crie `.claude/rules/minhas-regras.md`:

```markdown
---
paths:
  - "src/**/*.ts"
  - "src/**/*.tsx"
---

# Convenções TypeScript

- Use tipos de retorno explícitos em funções públicas
- Prefira `type` a `interface` para shapes de objetos
- Sem `any` — use `unknown` e narrow com type guards
```

**Quando usar rules vs CLAUDE.md:**

| Tipo de conteúdo | Onde vai |
|-----------------|----------|
| Regras universais do projeto (sempre relevantes) | `CLAUDE.md` — princípios inegociáveis |
| Convenções específicas de stack | `.claude/rules/` com `paths:` |
| Referência técnica detalhada | `memory/patterns.md` ou `decisions.md` |
| Instruções de tarefa | `.claude/skills/` |

**Padrões de caminho comuns:**

```yaml
# Frontend React/TypeScript
paths:
  - "src/**/*.{ts,tsx}"

# API / backend
paths:
  - "src/api/**"
  - "src/routes/**"

# Banco de dados / migrations
paths:
  - "db/migrations/**"
  - "prisma/schema.prisma"

# Testes
paths:
  - "**/*.test.{ts,js}"
  - "tests/**"
```

Rules sem `paths:` carregam incondicionalmente junto com CLAUDE.md.

Referência: https://code.claude.com/docs/en/memory#organize-rules-with-clauderules

---

## Adicionando um agente

Crie `.claude/agents/meu-agente.md`:

```markdown
---
name: meu-agente
description: O que este agente faz. Use proativamente quando [situação específica].
tools: Read, Glob, Grep
model: sonnet
---

# Agente: meu-agente

[System prompt — o que o agente é e como deve se comportar]
```

**Crítico: o campo `description`**

O orquestrador (Claude principal) lê **apenas a description** para decidir se delega.

```yaml
# Fraco — Claude pode não delegar quando deveria
description: "Ajuda com queries de banco de dados"

# Forte — Claude sabe exatamente quando chamar
description: "Analista SQL especialista. Use proativamente ao analisar dados,
escrever queries ou diagnosticar problemas de performance no banco."
```

**Isolamento e memória:**

| Cenário | Configuração |
|---------|-------------|
| Agente somente leitura (revisor, explorador) | `tools: Read, Glob, Grep` |
| Isolamento seguro — não toca nos arquivos de trabalho | `isolation: worktree` |
| Acumular conhecimento compartilhado | `memory: project` |
| Conhecimento pessoal (não compartilhado) | `memory: local` |
| Modelo mais rápido | `model: haiku` |
| Acesso total | omita `tools` (herda tudo) |

**Exemplo — agente de domínio:**

```markdown
---
name: security-reviewer
description: Especialista em segurança. Use proativamente após qualquer mudança em auth,
pagamentos ou dados de usuário. Revisa vulnerabilidades OWASP, injeção, exposição de secrets.
tools: Read, Glob, Grep
model: sonnet
isolation: worktree
---

Você é um engenheiro de segurança. Revise o código para:
- Vulnerabilidades de SQL/command injection
- Secrets ou credenciais hardcoded
- Falta de validação de inputs nas bordas do sistema
- Referências diretas a objetos inseguras
- Falta de rate limiting em endpoints sensíveis

Formato do relatório: Crítico (deve corrigir) → Aviso (deveria corrigir) → Informativo
```

Referência: https://code.claude.com/docs/en/sub-agents

---

## Configurando memória de agente

Agents com `memory: project` mantêm conhecimento persistente entre sessões em `.claude/agent-memory/<nome>/`.

**Habilitar memória em um agente existente:**

```yaml
---
name: code-reviewer
memory: project
---
```

**Instruir o agente a usar a memória:**

```markdown
## Uso da memória

Antes de iniciar qualquer revisão:
1. Leia sua memória de agente para padrões já descobertos
2. Aplique o conhecimento acumulado na revisão atual

Após concluir:
- Atualize a memória com novos padrões encontrados
- Registre problemas recorrentes no codebase
```

**Escopos de memória:**

| Escopo | Caminho | Usar quando |
|--------|---------|-------------|
| `project` | `.claude/agent-memory/<nome>/` | Conhecimento específico do projeto, útil para o time |
| `local` | `.claude/agent-memory-local/<nome>/` | Fluxo pessoal ou específico da máquina |
| `user` | `~/.claude/agent-memory/<nome>/` | Conhecimento para todos os projetos |

Referência: https://code.claude.com/docs/en/sub-agents#enable-persistent-memory

---

## Modificando os hooks

### Adicionar um padrão bloqueado

Em `.claude/hooks/block-destructive.sh`, adicione ao array `BLOCKED`:

```bash
BLOCKED=(
    # padrões existentes...
    "meu-comando-perigoso"
)
```

### Adicionar suporte a um novo formatador

Em `.claude/hooks/auto-format.sh`, adicione um case:

```bash
case "$EXT" in
    # cases existentes...
    lua)
        command -v stylua &>/dev/null && stylua "$FILE" 2>/dev/null
        ;;
esac
```

### Criar um novo hook de comando

1. Crie `.claude/hooks/meu-hook.sh`
2. `chmod +x .claude/hooks/meu-hook.sh`
3. Registre em `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/meu-hook.sh"
          }
        ]
      }
    ]
  }
}
```

**Formato correto de saída para PreToolUse:**

```bash
#!/usr/bin/env bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if echo "$COMMAND" | grep -q "meu-padrao"; then
    jq -n --arg reason "Bloqueado: motivo" '{
        hookSpecificOutput: {
            hookEventName: "PreToolUse",
            permissionDecision: "deny",
            permissionDecisionReason: $reason
        }
    }'
    exit 0  # exit 0 com JSON — NÃO exit 2
fi

exit 0  # permitir
```

### Criar um prompt hook (portão avaliado por IA)

Para portões de qualidade que exigem julgamento:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "O usuário está prestes a executar: $ARGUMENTS\n\nSe for um `git commit`, verifique se a mensagem segue Conventional Commits (tipo(escopo): descrição, tipos: feat/fix/refactor/docs/test/chore/perf, máx 72 chars na primeira linha).\n\nRetorne JSON: {\"decision\": \"allow\"} se válido ou não for um commit. {\"decision\": \"block\", \"reason\": \"explicação\"} se a mensagem for inválida.",
            "model": "haiku"
          }
        ]
      }
    ]
  }
}
```

### Hooks pessoais (settings.local.json)

Hooks pessoais que não devem ser compartilhados:

```bash
cp .claude/settings.local.json.example .claude/settings.local.json
# Edite para habilitar o auto-commit no SessionEnd ou adicionar seus próprios hooks
```

**Eventos disponíveis:** `SessionStart`, `SessionEnd`, `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `Stop`, `UserPromptSubmit`, `SubagentStart`, `SubagentStop`, `Notification`, `PreCompact`

Referência: https://code.claude.com/docs/en/hooks

---

## Adicionando referências de libs

Quando adicionar uma nova lib ou framework ao projeto, adicione sua documentação em `.claude/references.md`:

```markdown
## Deste Projeto

| Recurso | URL | Quando usar |
|---------|-----|-------------|
| Fastify | https://fastify.dev/docs/latest/ | Rotas, plugins, lifecycle |
| Prisma | https://www.prisma.io/docs | Schema, migrations, queries |
| Minha nova lib | https://docs.minhalib.com | [quando consultar] |
```

Claude consulta este arquivo antes de fazer web search.

---

## Customizando o CLAUDE.md

O CLAUDE.md é carregado em toda sessão — mantenha-o enxuto.

**O que vai no CLAUDE.md:**
- Protocolo de sessão (incluindo leitura do campo `language`)
- Regra de idioma
- Mapa de navegação
- Regras inegociáveis absolutas (máx 5-7)

**O que NÃO vai no CLAUDE.md:**

| Conteúdo | Onde vai |
|----------|----------|
| Regras técnicas detalhadas | `.claude/rules/` com `paths:` |
| Convenções específicas de stack | `.claude/rules/frontend.md`, `api.md`, etc. |
| Decisões e histórico | `memory/decisions.md` |
| O que funcionou/falhou | `memory/lessons.md` |
| Instruções de tarefa | `.claude/skills/` |

**Meta:** CLAUDE.md abaixo de 50 linhas. Cada linha extra é paga em tokens em toda sessão ao longo de toda a vida do projeto.

---

## Adotando o template em um projeto existente

Se o projeto já tem código e você quer adicionar esta estrutura:

```bash
# Na raiz do projeto existente
PROJECT_DIR="$(pwd)"
git clone --depth=1 https://github.com/ecodelearn/template-claude-code-ts.git /tmp/cc-template
cd /tmp/cc-template && npm install && npm run build
node dist/adopt.js --tool claude --target "$PROJECT_DIR"
cd "$PROJECT_DIR" && rm -rf /tmp/cc-template
```

O script copia `.claude/` e `CLAUDE.md` sem tocar em nenhum arquivo existente do projeto.

Em seguida, abra o Claude Code e execute `/project-adopt`. Diferente do `/project-init`, o `/project-adopt`:
1. Usa o agente `researcher` para ler `package.json`, configs de lint, git log, estrutura de diretórios
2. Chega à entrevista já com as respostas óbvias — você confirma, não responde do zero
3. Cria specs para features que já estão em andamento
4. Respeita as convenções existentes em vez de redefinir

**O que o `adopt.ts` copia e o que não copia:**

| Copiado | Não copiado |
|---------|-------------|
| `.claude/` inteiro | `README.md` do template |
| `CLAUDE.md` (se não existir) | `QUICKSTART.md` |
| `.gitignore` (se não existir) | `docs/` do template |

---

## Criando specs manualmente

Se preferir criar specs sem a skill `/spec-create`:

1. Copie `.claude/specs/_template.md` para `.claude/specs/[feature-slug].md`
2. Preencha todos os campos (remova os comentários HTML)
3. Preencha os **Critérios de aceite** antes de começar a implementar
4. Adicione ao `INDEX.md` na seção "Backlog"
5. Commit: `git add .claude/specs/ && git commit -m "docs(specs): add [feature-slug] spec"`
