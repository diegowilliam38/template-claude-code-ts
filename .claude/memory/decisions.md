# Decisões Arquiteturais

> Registre ANTES de implementar decisões significativas. Consulte antes de refatorar ou propor mudanças de arquitetura.

<!--
FORMATO DE ENTRADA:

## [Título da decisão] — YYYY-MM-DD
**Contexto:** por que essa decisão foi necessária
**Decisão:** o que foi escolhido
**Alternativas descartadas:** o que foi considerado e por que não foi escolhido
**Consequências:** impactos esperados (positivos e negativos)
**Status:** ativa | substituída por [link]
-->

<!-- Adicione entradas aqui -->

## Não portar `git-commit-formatter` e `license-header-adder` para os repos irmãos — 2026-07-06
**Contexto:** Ao mapear o gap entre os 3 templates (spec `chore-sync-template-ecosystem`), essas 2 das 5 skills exclusivas do `-ts` pareciam genéricas o bastante para virar universais (privado + `-open`), ao contrário das outras 3 (`adk-tool-scaffold`, `database-schema-validator`, `json-to-pydantic`), que são nichadas o suficiente para ficar só aqui.
**Decisão:** Não portar nenhuma das duas.
- `git-commit-formatter` duplica a skill `commit` que já existe em `template-claude-code`/`template-claude-code-open` — mesmo Conventional Commits, mesma finalidade, nomes diferentes. Portar criaria duas skills fazendo a mesma coisa, violando o próprio princípio "prefira sempre a solução mais simples" que o template exige do código que ele orienta.
- `license-header-adder` conflita com a filosofia de licença do próprio ecossistema: os 3 repos usam WTFPL v2, uma licença que existe justamente pra eliminar cerimônia de copyright/header. Adicionar uma skill que insere headers de licença formais é o oposto do que o template pratica.
**Alternativas descartadas:** Portar as duas como estão; renomear `git-commit-formatter` pra consolidar com `commit`.
**Consequências:** As 5 skills exclusivas do `-ts` continuam exclusivas — nenhuma mudança nos outros 2 repos. Se o `-ts` quiser eliminar a duplicação interna (`commit` vs `git-commit-formatter`), isso é uma limpeza separada, fora desta spec.
**Status:** ativa
