# Changelog

All notable changes. / Mudanças relevantes.
Format: [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added / Adicionado
- `SUPPORT.md` and this changelog.
- `permissions.deny` for `.env*`, `*.pem`, `*.key` and SSH keys in the repo's own
  `.claude/settings.json`; `block-destructive.sh` also blocks reading them through
  the shell (best-effort).

### Fixed / Corrigido
- `SECURITY.md` no longer says the npm package is unpublished.
