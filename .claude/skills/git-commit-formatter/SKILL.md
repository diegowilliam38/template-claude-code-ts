---
name: git-commit-formatter
description: Formats git commit messages using Conventional Commits. Use when the user asks to commit changes or write commit messages.
---

# Git Commit Formatter Skill

When writing commit messages, follow Conventional Commits.

## Format

`<type>[optional scope]: <description>`

## Allowed types

- `feat`: new feature
- `fix`: bug fix
- `docs`: documentation only
- `style`: formatting only
- `refactor`: internal code improvement
- `perf`: performance improvement
- `test`: tests added/updated
- `chore`: tooling/build/maintenance

## Instructions

1. Inspect staged/unstaged changes and identify the primary intent.
2. Pick one `type` and optional `scope`.
3. Write an imperative short description.
4. Add `BREAKING CHANGE:` footer when applicable.
5. Propose 1-3 candidate messages and mark one as recommended.

## Example

`feat(auth): add google login flow`
