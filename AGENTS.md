# Agent Instructions

Use este arquivo como contexto universal para ferramentas de coding agent.

## Session Protocol

1. Leia `.claude/memory/MEMORY.md` e respeite o campo `language`.
2. Leia `.claude/specs/INDEX.md` antes de iniciar qualquer task.
3. Consulte `.claude/memory/lessons.md` antes de decidir mudancas tecnicas.
4. Ao pausar/concluir, atualize spec + `INDEX.md`.
5. Registre aprendizados em `lessons.md`, `decisions.md` ou `patterns.md`.

> "The program should always respond to the user in the way that astonishes him least." - Law of Least Astonishment, Tao of Programming, 4.1

## Non-Negotiables

- Prefira solucoes simples e verificaveis.
- Nao repita erros ja registrados em `lessons.md`.
- Documente decisoes arquiteturais importantes.
- Stop-the-line em falhas inesperadas: preservar evidencia e replenejar.
- TDD Red/Green/Refactor: teste antes do codigo de producao (Red), minimo pra passar (Green), refatore sem quebrar (Refactor) - sem excecao.
- Done = criterios de aceite + testes + ciclo TDD verificado + verificacao documentada.
