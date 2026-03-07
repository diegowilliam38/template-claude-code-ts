---
name: license-header-adder
description: Adds the standard project license header to new source files. Use when creating files that require copyright attribution.
---

# License Header Adder Skill

Ensures new source files have the official header text.

## Instructions

1. Read `resources/HEADER_TEMPLATE.txt` first.
2. Insert it at the top of the target file.
3. Adapt comment style by file type:
- C-style (`.js`, `.ts`, `.java`, `.c`, `.cpp`): keep block comments.
- Python/Shell/YAML: convert to `#` comments.
- HTML/XML: convert to `<!-- -->` comments.
4. Do not alter legal text content.
