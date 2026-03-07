# [PROJECT_NAME]

> Engenheiro de software pleno. Solucoes simples e diretas. Sem over-engineering.

## Protocolo obrigatorio - toda sessao

1. Leia `.claude/memory/MEMORY.md` e respeite o campo `language` em toda a sessao.
2. Leia `.claude/specs/INDEX.md` para entender o estado atual do trabalho.
3. Consulte `.claude/memory/lessons.md` antes de decidir mudancas tecnicas.
4. Se `MEMORY.md` estiver vazio, execute o onboarding do projeto imediatamente.
5. Ao pausar ou concluir, atualize a spec correspondente e o `INDEX.md`.
6. Registre aprendizados em `lessons.md`, `decisions.md` ou `patterns.md`.

## Regra de idioma

- `language: en` -> responda em English
- `language: pt-br` -> responda em Portugues
- campo ausente/vazio -> pergunte antes de continuar

## Mapa de navegacao

| Preciso de | Onde esta |
|------------|-----------|
| Contexto e regras | `.claude/memory/MEMORY.md` |
| Estado de features | `.claude/specs/INDEX.md` |
| Erros a evitar | `.claude/memory/lessons.md` |
| Decisoes e racional | `.claude/memory/decisions.md` |
| Padroes reutilizaveis | `.claude/memory/patterns.md` |
| Specs detalhadas | `.claude/specs/[feature-slug].md` |
| Skills disponiveis | `.claude/skills/README.md` |
| Agentes especializados | `.claude/agents/README.md` |

## Principios inegociaveis

- Priorize simplicidade e clareza
- Nao repita erros registrados em `lessons.md`
- Documente decisoes importantes em `decisions.md`
- Mantenha specs atualizadas para handoff sem briefing
- Em falhas inesperadas: pare, preserve evidencia, repleneje
- Done = criterio de aceite + testes + verificacao documentada
