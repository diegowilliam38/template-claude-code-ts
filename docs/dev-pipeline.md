# Pipeline de desenvolvimento com IA (7 estágios)

Este guia traduz o `pipeline-dev-software.md` para o fluxo deste template.

## Mapa rápido

1. Requisitos: defina objetivo, escopo e fora do escopo na spec.
2. Design técnico: registre decisões e trade-offs na spec e em `memory/decisions.md`.
3. Planejamento: quebre em tarefas pequenas e verificáveis.
4. Build: implemente com contexto claro (spec + regras + memória).
5. Review: nunca aceite primeiro passe; revise edge cases, erros, segurança e performance.
6. Deploy: execute checklist de publicação e rollback.
7. Monitoramento: confirme métricas, logs e alertas pós-release.

## Como aplicar no template

- `/.claude/specs/_template.md` agora inclui:
  - seção "Pipeline (7 estágios)"
  - checklist de review
  - checklist de deploy e monitoramento
- Use `/spec-create` para iniciar uma spec já com estrutura de qualidade.
- Use `/pr-review` antes de abrir PR.
- Use `/deploy` antes de publicar.

## Regra prática

- Mudança pequena: simplifique, mas mantenha review mínimo.
- Mudança estrutural (auth, billing, schema): faça os 7 estágios completos.

## Critério de conclusão

Uma spec só está `done` quando:

- critérios de aceite estão satisfeitos
- verificação tem evidência real (comando + resultado)
- review/deploy/monitoramento foram tratados no nível adequado ao risco
