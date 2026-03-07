# Agent Instructions

Use este arquivo como contexto universal para ferramentas de coding agent.

## Session Protocol

1. Leia `.claude/memory/MEMORY.md` e respeite o campo `language`.
2. Leia `.claude/specs/INDEX.md` antes de iniciar qualquer task.
3. Consulte `.claude/memory/lessons.md` antes de decidir mudancas tecnicas.
4. Ao pausar/concluir, atualize spec + `INDEX.md`.
5. Registre aprendizados em `lessons.md`, `decisions.md` ou `patterns.md`.

## Non-Negotiables

- Prefira solucoes simples e verificaveis.
- Nao repita erros ja registrados em `lessons.md`.
- Documente decisoes arquiteturais importantes.
- Stop-the-line em falhas inesperadas: preservar evidencia e replenejar.
- Done = criterios de aceite + testes + verificacao documentada.
