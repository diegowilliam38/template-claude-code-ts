# Spec: chore-sync-template-ecosystem

**Status:** `in-progress`
**Slug:** `template-claude-code-ts::chore-sync-template-ecosystem`
**Sprint:** —
**Criado em:** 2026-07-06
**Última atualização:** 2026-07-06

---

## Objetivo

Alinhar os três templates do ecossistema (`template-claude-code` privado, `template-claude-code-open` público, `template-claude-code-ts` CLI multi-harness) como o mesmo produto — sem forçar paridade arquivo-a-arquivo onde a diferença é intencional.

## Contexto técnico

Mapeamento feito em 2026-07-06 (ver `20 Wiki/Tao of Programming` no vault) revelou três estágios de maturidade diferentes:
- `template-claude-code` (privado, PT-BR): template estático, cópia de trabalho ativa, fonte da verdade atual.
- `template-claude-code-open` (público, EN/bilíngue): mesmo template estático, era tradução congelada desde 2026-05-07 — já sincronizado com as citações do Tao of Programming (commits `dc66893`, `758fc59`).
- `template-claude-code-ts` (privado, não publicado no npm, parado desde 2026-03-07): **não é tradução** — é um CLI TypeScript (`src/adopt.ts`, `src/providers/{claude,gemini,antigravity}.ts`) que instala o template para múltiplos provedores, com 5 skills exclusivas (`adk-tool-scaffold`, `database-schema-validator`, `git-commit-formatter`, `json-to-pydantic`, `license-header-adder`) e um `GEMINI.md` reescrito (não espelho do `CLAUDE.md`).

O objetivo declarado do usuário é que os três sejam eventualmente "template funcional multi-harness", mas reconhecendo que o `-ts` tem investimento de engenharia próprio que não deve ser apagado por uma sincronização forçada.

## Pipeline (7 estágios)

- [ ] Requisitos definidos (objetivo, escopo, fora do escopo)
- [ ] Design técnico definido (arquitetura, libs, segurança)
- [ ] Planejamento quebrado em tarefas pequenas e verificáveis
- [ ] Build concluído com testes locais
- [ ] Review concluído (edge cases, erros, segurança, performance)
- [ ] Deploy preparado/executado com checklist
- [ ] Monitoramento definido (métricas, alertas, logs)

## Fora do escopo

- Republicar texto integral de terceiros (ver decisão do Tao of Programming — só citação curta e atribuída).
- Remover ou "simplificar" as skills exclusivas do `-ts` (`adk-tool-scaffold`, `database-schema-validator`, `git-commit-formatter`, `json-to-pydantic`, `license-header-adder`) para bater com os outros dois — são features reais, não drift.
- Decisão de publicação no npm em si — tratada como dependência futura, não parte desta spec.

## Decisões técnicas

- A definir na etapa de design. Pergunta central: quais elementos devem ser universais entre os 3 (ex.: protocolo de memória, princípios inegociáveis, citações do Tao) vs. específicos de cada canal (ex.: skills do `-ts`, bilinguismo do `-open`)?

## Dependências

- **Depende de:** nenhuma
- **Bloqueia:** decisão de publicar `template-claude-code-ts` no npm

## Arquivos relevantes

- `template-claude-code-ts/src/providers/{claude,gemini,antigravity}.ts` — abstração multi-provedor
- `template-claude-code-ts/GEMINI.md`, `CLAUDE.md`, `AGENTS.md` — mirrors por ferramenta
- `template-claude-code-ts/.claude/skills/` — 5 skills exclusivas a avaliar para portabilidade
- Cross-repo: `template-claude-code/CLAUDE.md`, `template-claude-code-open/CLAUDE.md` — referência do que já está sincronizado

## Critérios de aceite

- Mapa completo e explícito do que cada um dos 3 repos tem que os outros não têm.
- Decisão registrada (em `decisions.md`) sobre o que é universal vs. específico de canal.
- Citações do Tao of Programming portadas para o `-ts` nos arquivos equivalentes (`CLAUDE.md`, `GEMINI.md`, skills relevantes), respeitando o wording próprio do `GEMINI.md` (não é espelho literal do `CLAUDE.md`).
- Decisão explícita (mesmo que "adiar") sobre publicação no npm.

## Tarefas

- [x] Atualizar o clone local de `template-claude-code-ts` e revisar histórico completo desde `0b75bcd` (initial universal code-cli template)
- [x] Mapear feature gap completo entre os 3 repos (skills, docs, protocolo) — achado real: TDD Red/Green/Refactor tinha sumido do `-ts` inteiro (CLAUDE.md, AGENTS.md, GEMINI.md, code-reviewer.md, planner.md), provavelmente perdido na reescrita `e800c63`. `hooks/`, `researcher.md`, `.claude/rules/` e `.claude/references.md` são idênticos nos 3 — sem drift aí.
- [x] Portar citações do Tao of Programming para `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `spec-create/SKILL.md`, `bugfix/SKILL.md` e `docs/team-workflow.md` do `-ts` (commit `40d3329`)
- [x] Restaurar a disciplina de TDD Red/Green/Refactor que faltava em `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `code-reviewer.md`, `planner.md` e `bugfix/SKILL.md` (mesmo commit `40d3329`)
- [ ] Decidir com o usuário o que fazer com as 2 skills genéricas do `-ts` (`git-commit-formatter`, `license-header-adder`) — candidatas a também existir no privado/`-open`, diferente das outras 3 (`adk-tool-scaffold`, `database-schema-validator`, `json-to-pydantic`) que são nichadas e cabem só aqui
- [ ] Registrar decisão de publicação (ou adiamento) no npm em `decisions.md`
- [x] Atualizar `20 Wiki/Tao of Programming` e `20 Wiki/Agentes/Template Claude Code` no vault com o resultado

---

## Como retomar este trabalho

**Estado atual:** Gap mapeado, TDD restaurado e citações do Tao portadas (commit `40d3329`, push em `master`). Falta só a decisão sobre as 2 skills genéricas e a decisão de publicação no npm.
**Próximo passo:** Perguntar ao usuário se `git-commit-formatter` e `license-header-adder` devem ser portadas para `template-claude-code` e `template-claude-code-open`; registrar a resposta em `decisions.md`.
**Bloqueadores:** nenhum.

---

## Verificação

<!-- Preencher ao concluir. -->

## Checklist de review

- [ ] Inputs externos validados
- [ ] Tratamento de erro explícito
- [ ] Edge cases críticos cobertos por teste
- [ ] Sem regressão de performance relevante
- [ ] Segurança revisada (auth, permissões, secrets, injection)

## Checklist de deploy e monitoramento

- [ ] Plano de rollout definido (migração, compatibilidade, fallback)
- [ ] Logs e métricas adicionados/ajustados
- [ ] Alertas definidos para falhas principais
- [ ] Pós-deploy validado em produção (ou ambiente equivalente)

## Notas de implementação

- Repo clonado localmente em `/tmp/claude-1000/-home-ecode/63813cbf-56e1-4342-8757-280286e1ad4f/scratchpad/template-claude-code-ts` (sessão de 2026-07-06) — mover para local definitivo antes de retomar o trabalho, já que scratchpad é temporário.
