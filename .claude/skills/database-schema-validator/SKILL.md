---
name: database-schema-validator
description: Validates SQL schema files against safety and naming policies using a deterministic validator script.
---

# Database Schema Validator Skill

Use a script for validation instead of visual inspection.

## Policies

1. Forbid `DROP TABLE`.
2. Enforce `snake_case` table names.
3. Require `id` primary key for each table.

## Instructions

1. Run:
`python scripts/validate_schema.py <schema_file>`
2. If exit code is `0`, report success.
3. If exit code is `1`, report errors and suggested fixes.
