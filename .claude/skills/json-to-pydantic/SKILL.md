---
name: json-to-pydantic
description: Converts JSON snippets into Python Pydantic models using project examples and typing conventions.
---

# JSON to Pydantic Skill

Transforms raw JSON into typed Pydantic models.

## Instructions

1. Parse the JSON structure from user input.
2. Infer types:
- `string` -> `str`
- `number` -> `int` or `float`
- `boolean` -> `bool`
- `array` -> `List[T]`
- `null` -> `Optional[T]`
- nested object -> separate class
3. Follow style from examples:
- `examples/input_data.json`
- `examples/output_model.py`
4. Use `PascalCase` for classes and explicit typing imports.
5. Default nullable fields to `None`.
