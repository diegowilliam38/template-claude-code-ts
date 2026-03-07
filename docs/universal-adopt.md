# Adopt CLI universal (TypeScript)

A adocao de templates para ferramentas de code-cli agora usa um core em TypeScript com providers.

## Como usar

### Opção 1 (recomendada): via npm script

```bash
npm install
npm run adopt -- --tool claude --target /caminho/para/projeto
```

### Opção 2: execução direta do build

```bash
npm install
npm run build
node dist/adopt.js --tool claude --target /caminho/para/projeto
```

### Opção 3 (Windows PowerShell)

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\adopt.ps1 -Tool claude -Target C:\caminho\para\projeto
```

### Opção 4: instalação global local (sem repetir build)

```bash
npm install
npm run build
npm link

# Em qualquer projeto git:
adopt --tool claude --target .
```

Argumentos:

- `--tool`: provider da ferramenta (ex.: `claude`)
- `--source`: repositorio git ou caminho local do template (opcional)
- `--target`: diretorio de destino (padrao: diretorio atual)
- `--yes`: aceita sobrescritas sem prompt

### Notas para `--tool antigravity`

- Copia `GEMINI.md` e `AGENTS.md` (sem sobrescrever se ja existirem).
- Copia skills para `.agent/skills` (escopo do workspace no Antigravity).
- Nao copia `.claude/` (modo minimalista para Antigravity).
- Para skills globais do usuario, use `~/.gemini/antigravity/skills/<skill-folder>/`.

Parâmetros no PowerShell:

- `-Tool`: provider da ferramenta
- `-Source`: repositório git ou caminho local do template
- `-Target`: diretório de destino
- `-Yes`: aceita sobrescritas sem prompt

## Arquitetura

- `src/adopt.ts`: engine de copia, prompts e resolucao de source
- `src/types.ts`: contrato `ToolProvider`
- `src/providers/*.ts`: regras especificas por ferramenta

## Como adicionar outra tool

1. Crie um novo provider em `src/providers/<tool>.ts` implementando `ToolProvider`.
2. Registre no mapa em `src/providers/index.ts`.
3. Defina `copyRules`, `nextSteps` e `afterCopy` conforme a ferramenta.

Com isso, o core continua o mesmo e voce troca apenas o comportamento por provider.
